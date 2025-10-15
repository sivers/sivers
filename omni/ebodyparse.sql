-- interpolate {variables} in an email body
-- populating them with fields from people table or related
create function o.ebodyparse(_body text, _pid integer, out parsed text) as $$
declare
	p people;
begin
	parsed = $1;
	select * into p from people where id = $2;
	if strpos(parsed, '{id}') > 0 then
		parsed = replace(parsed, '{id}', p.id::text);
	end if;
	if strpos(parsed, '{greeting}') > 0 then
		parsed = replace(parsed, '{greeting}', coalesce(p.greeting, 'you'));
	end if;
	if strpos(parsed, '{name}') > 0 then
		parsed = replace(parsed, '{name}', p.name);
	end if;
	if strpos(parsed, '{lopass}') > 0 then
		parsed = replace(parsed, '{lopass}', coalesce(p.lopass, 'zzzz'));
	end if;
	if strpos(parsed, '{temp}') > 0 then
		parsed = replace(parsed, '{temp}', (
			select temp from o.temp_add(p.id)
		));
	end if;
	if strpos(parsed, '{email}') > 0 then
		parsed = replace(parsed, '{email}', (coalesce((
			select string_agg(ats.email, ' or ') from ats where person_id = p.id
		), '????')));
	end if;
	-- nownownow.com :
	if strpos(parsed, '{public_id}') > 0 then
		parsed = replace(parsed, '{public_id}', (coalesce((
			select public_id from now_profiles where id = p.id
		), '????')));
	end if;
	-- (and if they have more than one now_page, well, that's life)
	if strpos(parsed, '{short}') > 0 then
		parsed = replace(parsed, '{short}', (coalesce((
			select short from now_pages where person_id = p.id order by id limit 1
		), '????')));
	end if;
	if strpos(parsed, '{long}') > 0 then
		parsed = replace(parsed, '{long}', (coalesce((
			select long from now_pages where person_id = p.id order by id limit 1
		), '????')));
	end if;
end;
$$ language plpgsql;

