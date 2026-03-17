-- big
create function peep.email_view(kk char(32), _id integer,
	out head text, out body text) as $$
declare
	pid integer;
	-- using "0" suffix to distinguish from table names
	email0 jsonb;
	attachments0 jsonb;
	person0 jsonb;
	ats0 jsonb;
	emails0 jsonb;
	urls0 jsonb;
	tags0 jsonb;
	stats0 jsonb;
	formletters0 jsonb;
begin
	select person_id into pid
	from logins
	where logins.cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;

	email0 = to_jsonb(r) from (
		select id, person_id, category,
		created_at::date, created_by,
		opened_at::date, opened_by,
		closed_at::date, closed_by, reference_id,
		their_email, their_name,
		subject, headers, emails.body, message_id, outgoing
		from emails
		where id = $2
	) r;
	if email0 is null or email0 ->> 'person_id' is null then
		head = e'303\r\nLocation: /';
		return;
	end if;
	-- if email has never been opened, open now
	if email0 ->> 'opened_by' is null then
		update emails
		set opened_by = pid, opened_at = now()
		where id = $2;
	end if;

	attachments0 = coalesce((select jsonb_agg(r) from (
		select id, filename
		from attachments
		where email_id = $2
		order by id
	) r), '[]');

	person0 = to_jsonb(r) from (
		select * from people where id = (email0 -> 'person_id')::integer
	) r;

	ats0 = coalesce((select jsonb_agg(r) from (
		select email, used::date, listype
		from ats
		where person_id = (email0 -> 'person_id')::integer
		order by used desc nulls last
	) r), '[]');

	emails0 = coalesce((select jsonb_agg(r) from (
		select id, created_at::date, subject
		from emails
		where person_id = (email0 -> 'person_id')::integer
		order by id desc
	) r), '[]');

	urls0 = coalesce((select jsonb_agg(r) from (
		select id, url, main
		from urls
		where person_id = (email0 -> 'person_id')::integer
		order by main desc nulls last, id asc
	) r), '[]');

	tags0 = coalesce((select jsonb_agg(r) from (
		select tag, very, created_at
		from ptags
		where person_id = (email0 -> 'person_id')::integer
		order by created_at, tag
	) r), '[]');

	stats0 = coalesce((select jsonb_agg(r) from (
		select id, statkey, statvalue, created_at
		from stats
		where person_id = (email0 -> 'person_id')::integer
		order by id
	) r), '[]');

	formletters0 = (select jsonb_agg(r) from (
		select id, accesskey, title, explanation, f.body
		from formletters f
		where accesskey is not null
		order by accesskey
	) r);

	body = o.template('peep-wrap', 'peep-email', jsonb_build_object(
		'email', email0,
		'attachments', attachments0,
		'person', person0,
		'ats', ats0,
		'emails', emails0,
		'urls', urls0,
		'tags', tags0,
		'stats', stats0,
		'formletters', formletters0
	));
end;
$$ language plpgsql;

