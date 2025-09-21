-- use tempcode to set cookie
create function mynow.login(_temp char(16), _id int,
	out head text, out body text) as $$
declare
	cookie text;
begin
	select temp_use.cookie into cookie
	from o.temp_use($1, $2);
	if cookie is null then
		-- could maybe show page of explanation instead?
		head = e'303\r\nLocation: /f';
	else
		head = concat(e'303\r\nSet-Cookie: ok=', cookie, e'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /');
	end if;
end;
$$ language plpgsql;

