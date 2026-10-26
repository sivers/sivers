create function mynow.urldel(kk char(32), urlid int,
	out head text, out body text) as $$
declare
	pid integer;
begin
	pid = mynow.auth($1);
	if pid is null then
		head = e'303\r\nLocation: /f';
		return;
	end if;
	delete from urls where person_id = pid and id = $2;
	head = e'303\r\nLocation: /urls';
end;
$$ language plpgsql;

