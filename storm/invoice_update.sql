-- update invoice name/info/notes, etc - then redirect to view
create function storm.invoice_update(kki char(32), invid integer, nu json,
	out head text, out body text) as $$
declare
	admin integer;
begin
	-- first, web app auth
	select admin_auths.person_id into admin
	from logins
	join admin_auths on logins.person_id = admin_auths.person_id
	where logins.cookie = $1
	and admin_auths.appcode = 'storm';
	if admin is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;
	-- total, code, and shipcost are calculated, so don't update
	-- add2, shipdate: null if empty
	perform o.update_black('invoices', $2, $3, '{id,created,total,code,shipcost}', '{add2,shipdate}');
	-- go back to view
	head = e'303\r\nLocation: /invoice/' || $2;
end;
$$ language plpgsql;

