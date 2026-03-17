create function mynow.profileset(kk char(32), qcode text, answer text,
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
		if $2 = 'title' then
			update now_profiles set title = btrim($3) where id = pid;
		elsif $2 = 'liner' then
			update now_profiles set liner = btrim($3) where id = pid;
		elsif $2 = 'why' then
			update now_profiles set why = btrim($3) where id = pid;
		elsif $2 = 'thought' then
			update now_profiles set thought = btrim($3) where id = pid;
		elsif $2 = 'red' then
			update now_profiles set red = btrim($3) where id = pid;
		end if;
		head = e'303\r\nLocation: /profile';
	end if;
end;
$$ language plpgsql;

