-- add all digital items to an invoice, then mark it paid
create function stork.giftall(_invoiceid integer,
	out head text, out body text) as $$
begin
	insert into lineitems (invoice_id, item_id, quantity) values ($1, 10, 1);
	insert into lineitems (invoice_id, item_id, quantity) values ($1, 20, 1);
	insert into lineitems (invoice_id, item_id, quantity) values ($1, 30, 1);
	insert into lineitems (invoice_id, item_id, quantity) values ($1, 40, 1);
	insert into lineitems (invoice_id, item_id, quantity) values ($1, 50, 1);
	perform store.invoice_id_paid($1, 'derek gift all');
	head = e'303\r\nLocation: /invoice/' || $1;
end;
$$ language plpgsql;

