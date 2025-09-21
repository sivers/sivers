-- update city, state, country
-- URL for this is just /, so if trouble, return to 'Location: /'
create function mynow.whereset(kki char(32), _city text, _state text, _country char(2),
	out head text, out body text) as $$
declare
	pid integer;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	elsif $4 is null or $4 = '' then -- needs country at least
		head = e'303\r\nLocation: /?again';
	else
		-- if $2 or $3 is empty, set to null  (there is no city named '')
		update people set
			city  = case when btrim($2) = '' then null else btrim($2) end,
			state = case when btrim($3) = '' then null else btrim($3) end,
			country = $4  -- wrong value will cause exception
		where id = pid;
		head = e'303\r\nLocation: /urls';
	end if;
exception when others then
	head = e'303\r\nLocation: /?err';
end;
$$ language plpgsql;

