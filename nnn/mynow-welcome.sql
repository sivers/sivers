create function mynow.welcome(kki char(32), _tempcode char(16),
	out head text, out body text) as $$
declare
	pid integer;
begin
	perform 1 from logins where cookie = $1;
	if found then
		head = e'303\r\nLocation: /';
	else
		select person_id into pid from o.temp_get($2);
		if pid is null then
			body = o.template('mynow-wrap', 'mynow-authform', jsonb_build_object('message', 'Let’s email you a new login link'));
		else
			body = o.template('mynow-wrap', 'mynow-welcome', (select to_jsonb(r) from (select * from o.temp_get($2)) r));
		end if;
	end if;
end;
$$ language plpgsql;

