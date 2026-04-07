create function me.comment_post(_formdata jsonb,
	out head text, out body text) as $$
declare
	pid integer;
begin
	-- Form submitted URI not in my URIs? Stop now
	perform 1 from articles where uri = $1->>'uri';
	if not found then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	-- Location: /thanks as a hard fail clear intention to spam
	if lower(regexp_replace($1->>'name', '\s+', '', 'g')) ~ '^test$|crypto' or
	lower($1->>'email') ~ '^test@|@example' then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	-- this function only fails (returning null) if name or email is malformed
	select x.pid into pid
	from o.person_create($1->>'name', $1->>'email') x;
	if pid is null then
		head = e'303\r\nLocation: /' || $1->>'uri';
		return;
	end if;

	insert into comments (person_id, uri, name, email, comment)
	values (pid,
		$1->>'uri',
		o.clean_name($1->>'name'),
		o.clean_email($1->>'email'),
		regexp_replace($1->>'comment', '</?[^>]+?>', '', 'g'));

	update ats set used = now() where email = o.clean_email($1->>'email');

	perform o.iplog(pid, ($1->>'ip')::inet);

	body = o.template('me-wrap', 'me-commentpost', jsonb_build_object(
		'uri', $1->>'uri',
		'name', o.clean_name($1->>'name')
	));
end;
$$ language plpgsql;

