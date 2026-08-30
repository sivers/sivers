create function me.comment_post(_formdata jsonb,
	out head text, out body text) as $$
declare
	_email text;
	_comment text;
	pid integer;
	pname text;
begin
	-- clean email: lowercase and no whitespace
	_email = o.clean_email($1->>'email');
	-- clean comment: remove \r and tags
	_comment = regexp_replace(replace($1->>'comment', e'\r', ''), '</?[^>]+?>', '', 'g');

	-- Form submitted URI not in my URIs? Stop now
	perform 1 from articles where uri = $1->>'uri';
	if not found then
		head = e'303\r\nLocation: /thanks';
		return;
	end if;

	-- Email address known?
	select person_id into pid from ats where email = _email;
	if pid is null then
		-- NO! UNKNOWN. Show email and comment, telling to contact me
		body = o.template('me-wrap', 'me-commentno', jsonb_build_object(
			'uri', $1->>'uri',
			'email', _email,
			'comment', _comment
		));
	else
		-- YES! KNOWN 
		-- log
		update ats set used = now() where email = email;
		perform o.iplog(pid, ($1->>'ip')::inet);

		-- "greeting" = usually their first name
		select greeting into pname from people where id = pid;

		-- new comment sends notify, so ding rewrites the article page
		insert into comments (person_id, uri, name, email, comment)
		values (pid, $1->>'uri', pname, _email, _comment);

		-- say thanks. link to article, articles, contact, home.
		body = o.template('me-wrap', 'me-commentpost', jsonb_build_object(
			'uri', $1->>'uri',
			'name', pname
		));
	end if;
end;
$$ language plpgsql;

