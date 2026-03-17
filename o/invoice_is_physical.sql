-- has physical items?
create function o.invoice_is_physical(_invid integer) returns boolean as $$
	select exists (
		select lineitems.id from lineitems
		join items on (lineitems.item_id = items.id and items.weight > 0)
		where lineitems.invoice_id = $1
	);
$$ language sql;
