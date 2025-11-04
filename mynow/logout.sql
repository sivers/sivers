create function mynow.logout(kk char(32),
	out head text, out body text) as $$
begin
	delete from logins where cookie = $1;
	head = e'303\r\nSet-Cookie: ok=; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=0\r\nLocation: /f';
end;
$$ language plpgsql;

