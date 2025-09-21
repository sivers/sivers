-- Yes this jsonb array is the source of the nownownow.com profile questions and example answers
-- 2nd param = NULL unless they want to edit one specific already-finished answer
-- for each one, if not done, (or 2nd param chose) set code question for template: mynow-profile1
-- but if all done, load qas array of codes, questions, answers for template: mynow-profile
create function mynow.profile(kki char(32), _code1 varchar(8),
	out head text, out body text) as $$
declare
	pid integer;
	p now_profiles;
	qas jsonb = '[
	{"code":"title","question":"Professional title?","exs":
		["Freelance web developer",
		"Director of marketing at Pixar",
		"Singer/songwriter"]},
	{"code":"liner","question":"What do you actually do? (in one sentence)","exs":
		["I tell stories, some of which are true, and I turn ideas into words.",
		"I help students study, work, and achieve their goals more effectively.",
		"I gather broken bottles from the train tracks of life and toss them at pedestrians."]},
	{"code":"why","question":"Why do you do it? (just 1-3 sentences)","exs":
		["I write because I have a lot of questions and frustrations to rant about.",
		"I love to create things out of nothing and care a lot about freedom. Software development is the sweet spot for this."]},
	{"code":"thought","question":"Recent thought, epiphany, or interesting idea","exs":
		["No beliefs are necessarily true. That’s why we have to say ‘I believe...’ instead of just pointing at the proof.",
		"The traveler sees what he sees, the tourist sees what he has come to see."]},
	{"code":"red","question":"Recommended book or article? (title and author)","exs":
		["Atomic Habits by James Clear",
		"The Gardener and the Carpenter by Alison Gopnik"]}
	]';
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		select * into p from now_profiles where id = pid;
		if p.id is null then -- no profile? weird
			head = e'303\r\nLocation: /f?m=uninvited';
		else
			-- from qas array pull out next unanswered one in this format:
			-- {"code":_, "question":_, "exs":["example","answers"]}
			if p.title is null then
				body = o.template('mynow-headfoot', 'mynow-profile1', qas -> 0);
			elsif p.liner is null then
				body = o.template('mynow-headfoot', 'mynow-profile1', qas -> 1);
			elsif p.why is null then
				body = o.template('mynow-headfoot', 'mynow-profile1', qas -> 2);
			elsif p.thought is null then
				body = o.template('mynow-headfoot', 'mynow-profile1', qas -> 3);
			elsif p.red is null then
				body = o.template('mynow-headfoot', 'mynow-profile1', qas -> 4);
			-- none unanswered and wants to edit one?  (and that code exists in qas?)
			elsif $2 is not null and jsonb_path_query_first(qas, format('$[*] ? (@.code == "%s")', $2)::jsonpath) is not null then
				body = o.template('mynow-headfoot', 'mynow-profile1',
					-- first get {"code":_, "question":_, "exs":[]} from qas
					jsonb_path_query_first(qas, format('$[*] ? (@.code == "%s")', $2)::jsonpath)
					-- .. and merge it with {"answer":"their answer from now_profiles for column $2"}
					|| jsonb_build_object('answer', to_jsonb(p) ->> $2));
			-- none unanswered and no edits? different template: show all answers, with edit links
			else
				-- {"public_id":_", "qas":[{"code":_, "question":_, "answer":_},{"code":_, "question":_, "answer":_}]}
				body = o.template('mynow-headfoot', 'mynow-profile', jsonb_build_object(
					'public_id', to_jsonb(p) -> 'public_id',
					'qas', jsonb_build_array(
					json_build_object('code', 'title',   'question', qas -> 0 ->> 'question', 'answer', to_jsonb(p) -> 'title'),
					json_build_object('code', 'liner',   'question', qas -> 1 ->> 'question', 'answer', to_jsonb(p) -> 'liner'),
					json_build_object('code', 'why',     'question', qas -> 2 ->> 'question', 'answer', to_jsonb(p) -> 'why'),
					json_build_object('code', 'thought', 'question', qas -> 3 ->> 'question', 'answer', to_jsonb(p) -> 'thought'),
					json_build_object('code', 'red',     'question', qas -> 4 ->> 'question', 'answer', to_jsonb(p) -> 'red')
				)));
			end if;
		end if;
	end if;
end;
$$ language plpgsql;

