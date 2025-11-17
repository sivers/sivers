-- add a new lineitem to this invoice, then redirect to view invoice again
create function storm.lineitem_add(kki char(32), invid integer, itemid integer,
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
	-- add 1 of lineitem. triggers should update totals
	insert into lineitems (invoice_id, item_id, quantity)
	values ($2, $3, 1);
	head = e'303\r\nLocation: /invoice/' || $2;
end;
$$ language plpgsql;

