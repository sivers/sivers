-- button on a /person page to make a new empty invoice for this person
-- but if they have an open cart invoice, use that!
create function stork.invoice_create(_pid integer,
	out head text, out body text) as $$
declare
	invid integer;
begin
	select id into invid
	from invoices
	where person_id = $1
	and status = 'cart';
	if invid is null then
		insert into invoices (person_id)
		values ($1)
		returning id into invid;
	end if;
	head = e'303\r\nLocation: /invoice/' || invid;
end;
$$ language plpgsql;

