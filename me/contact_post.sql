create function me.contact_post(_formdata jsonb,
	out head text, out body text) as $$
declare
	pid integer;
begin
	-- Form submitted country not in my country list? Stop now
	perform 1 from countries where code = $1->>'country';
	if not found then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	-- Location: /thanks as a hard fail clear intention to spam
	if length(coalesce($1->>'url', '')) > 0 or
	lower(regexp_replace($1->>'name', '\s+', '', 'g')) = 'test' or
	lower($1->>'email') ~ '^test@|@example' then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	-- Location: /contact as a soft fail maybe mistake, do-over
	if regexp_replace(lower($1->>'sivers'), '[^a-z]+', '', 'g') != 'sivers' then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	-- this function only fails (returning null) if name or email is malformed
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

	update ats set used = now() where email = o.clean_email($1->>'email');

	perform o.iplog(pid, ($1->>'ip')::inet);

	perform o.send_formletter(pid, 1);

	body = o.template('me-wrap', 'me-contactpost', jsonb_build_object(
		'email', o.clean_email($1->>'email'),
		'name', o.clean_name($1->>'name')
	));
end;
$$ language plpgsql;

