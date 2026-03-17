create function mynow.urldel(kk char(32), urlid int,
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
		delete from urls where person_id = pid and id = $2;
		head = e'303\r\nLocation: /urls';
	end if;
end;
$$ language plpgsql;

