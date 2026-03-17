create function peep.login(_email text, _pass text,
	out head text, out body text) as $$
declare
	pid integer;
	cookie text;
begin
	select o.admin_auth($1, $2, 'peep') into pid;
	if pid is null then
		head = e'303\r\nLocation: /login';
	else
		select o.login(pid) into cookie;
		head = concat(e'303\r\nSet-Cookie: ok=', cookie, e'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /');
	end if;
end;
$$ language plpgsql;

