-- add one item to an invoice
create function stork.lineitem_add(_invoiceid integer, _itemid integer,
	out head text, out body text) as $$
begin
	insert into lineitems (invoice_id, item_id, quantity)
        values ($1, $2, 1);
	head = e'303\r\nLocation: /invoice/' || $1;
end;
$$ language plpgsql;

