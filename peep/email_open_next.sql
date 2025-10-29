create function peep.email_open_next(kki char(32), _cat text,
	out head text, out body text) as $$
declare
	pid integer;
begin
	select person_id into pid
	from logins
	where logins.cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;
	body = o.template('peep-wrap', 'peep-page', jsonb_build_object(
		'id', $2,
		'person_id', pid
	));
end;
$$ language plpgsql;

