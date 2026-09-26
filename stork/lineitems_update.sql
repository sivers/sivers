-- update quantities of lineitems in this invoice
-- $2 = JSON array of [{"id": 12345, "quantity": 1}, {"id": 12346, "quantity": 0}]
create function stork.lineitems_update(_invid integer, _lineitems jsonb,
	out head text, out body text) as $$
begin
	update lineitems
	set quantity = x.quantity
	from jsonb_to_recordset($2) as x(id integer, quantity smallint)
	where lineitems.id = x.id
	and lineitems.invoice_id = $1;

	head = e'303\r\nLocation: /invoice/' || $1;
end;
$$ language plpgsql;
