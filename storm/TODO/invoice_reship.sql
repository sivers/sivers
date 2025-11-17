	insert into invoices (person_id, currency, total, status,
		payment, paydate, payinfo, shipcost,
		shipname, addr1, addr2, city, state, postcode, country,
		phone, gift_note)
	select person_id, currency, total, 'ship',
		payment, paydate, 'reship of ' || $1, shipcost,
		shipname, addr1, addr2, city, state, postcode, country,
		phone, gift_note
	from invoices
	where id = $1
	returning id into newid;
	insert into lineitems (invoice_id, item_id, quantity, price)
	select newid, item_id, quantity, lineitems.price
	from lineitems
	join items on lineitems.item_id = items.id
	where lineitems.invoice_id = $1
	and items.weight > 0;
