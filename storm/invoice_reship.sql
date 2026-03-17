-- lost order? copy old invoice into new with status 'ship', then view it
create function storm.invoice_reship(kki char(32), oldid integer,
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
	-- copy invoice info
	insert into invoices (person_id, currency, total, status,
		payment, paydate, payinfo, shipcost, warehouse,
		shipname, addr1, addr2, city, state, postcode, country,
		phone, gift_note)
	select person_id, currency, total, 'ship',
		payment, paydate, 'reship of ' || $2, shipcost, warehouse,
		shipname, addr1, addr2, city, state, postcode, country,
		phone, gift_note
	from invoices
	where id = $2
	returning id into newid;
	-- copy just lineitems that need shipping
	insert into lineitems (invoice_id, item_id, quantity, price)
	select newid, item_id, quantity, lineitems.price
	from lineitems
	join items on lineitems.item_id = items.id
	where lineitems.invoice_id = $2
	and items.weight > 0;
	-- let's go look
	head = e'303\r\nLocation: /invoice/' || newid;
end;
$$ language plpgsql;

