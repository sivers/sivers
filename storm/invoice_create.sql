-- create a new invoice for this person then redirect to view
create function storm.invoice_create(kki char(32), owner integer,
	out head text, out body text) as $$
declare
	admin integer;
	newid integer;
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
	-- create new, and jump to it
	insert into invoices(person_id)
	values($2)
	returning id into newid;
	head = e'303\r\nLocation: /invoice/' || newid;
end;
$$ language plpgsql;

