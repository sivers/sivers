create function mynow.urladd(kk char(32), aurl text,
	out head text, out body text) as $$
declare
	pid integer;
begin
	pid = mynow.auth($1);
	if pid is null then
		head = e'303\r\nLocation: /f';
		return;
	end if;
	insert into urls (person_id, url, main)
	values (pid, o.clean_url($2), false);
	head = e'303\r\nLocation: /urls';
exception when others then
	head = e'303\r\nLocation: /urls?err';
end;
$$ language plpgsql;

