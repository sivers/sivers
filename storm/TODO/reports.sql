declare
	salesum json;
	newest json;
begin
	salesum = json_agg(r) from (
		select items.id, items.name, sum(lineitems.quantity)
		from lineitems
		join items on lineitems.item_id = items.id
		join invoices on lineitems.invoice_id = invoices.id
		where invoices.status != 'cart'
		group by items.id, items.name
		order by items.id
	) r;
	newest = json_agg(r) from (
		select invoices.id, invoices.person_id, people.name,
		invoices.created, invoices.paydate, invoices.status, invoices.currency, invoices.total
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status != 'cart'
		order by invoices.id desc
		limit 500
	) r;
	ok = true;
	js = json_build_object('salesum', salesum, 'newest', newest);
