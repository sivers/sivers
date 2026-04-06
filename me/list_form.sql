create function me.list_form(_pid integer, _lopass text,
	out head text, out body text) as $$
declare
	pid integer;
	name text;
begin
	select people.id, people.name into pid, name
	from people
	where id = $1 and lopass = $2;
	if pid is null then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	body = o.template('me-wrap', 'me-listform', jsonb_build_object(
		'id', pid,
		'lopass', $2,
		'name', name
	));
end;
$$ language plpgsql;

