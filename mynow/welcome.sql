create function mynow.welcome(kk char(32), _tempcode char(16),
	out head text, out body text) as $$
declare
	pid integer;
begin
	-- reverse auth: if valid login cookie, go logged-in home, not here
	pid = mynow.auth($1);
	if pid is not null then
		head = e'303\r\nLocation: /';
		return;
	end if;
	-- tempcode was emailed. use it to get person_id
	select person_id into pid from o.temp_get($2);
	if pid is null then
		body = o.template('mynow-wrap', 'mynow-authform', jsonb_build_object('message', 'Let’s email you a new login link'));
	else
		body = o.template('mynow-wrap', 'mynow-welcome', (select to_jsonb(r) from (select * from o.temp_get($2)) r));
	end if;
end;
$$ language plpgsql;

