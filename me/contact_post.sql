create or replace function me.contact_post(_formdata jsonb,
	out head text, out body text) as $$
declare
	pid integer;
	eid integer;
begin
	perform 1 from countries where code = $1->>'country';
	if not found then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	if length(coalesce($1->>'url', '')) > 0 then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	if regexp_replace(lower($1->>'sivers'), '[^a-z]+', '', 'g') != 'sivers' then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	select x.pid into pid
	from o.person_create($1->>'name', $1->>'email') x;
	if pid is null then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	update people
	set city = o.clean_name($1->>'city'),
	state = o.clean_name($1->>'state'),
	country = $1->>'country'
	where id = pid;

	perform o.iplog(pid, ($1->>'ip')::inet);

	select * into eid from o.send_formletter(pid, 1);

	body = o.template('me-wrap', 'me-contactpost', jsonb_build_object(
		'email', o.clean_email($1->>'email'),
		'name', o.clean_name($1->>'name')
	));
end;
$$ language plpgsql;

