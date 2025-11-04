create function mynow.urladd(kk char(32), aurl text,
	out head text, out body text) as $$
declare
	pid integer;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		insert into urls (person_id, url, main)
		values (pid, o.clean_url($2), false);
		head = e'303\r\nLocation: /urls';
	end if;
exception when others then
	head = e'303\r\nLocation: /urls?err';
end;
$$ language plpgsql;

