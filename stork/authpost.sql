create function storm.authpost(_email text, _pass text,
	out head text, out body text) as $$
declare
	pid integer;
	kk char(32);
begin
	select admin_auths.person_id into pid
	from admin_auths
	join admins on admin_auths.person_id = admins.person_id
	where admin_auths.person_id = o.pid_from_email($1)
	and admins.hashpass = crypt($2, admins.hashpass)
	and admin_auths.appcode = 'storm';
	if pid is null then
		head = e'303\r\nLocation: /login';
	else
		select cookie into kk from logins where person_id = pid;
		if kk is null then
			insert into logins (person_id) values (pid)
			returning cookie into kk;
		end if;
		head = concat(e'303\r\nSet-Cookie: ok=', kk, e'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /');
	end if;
end;
$$ language plpgsql;

