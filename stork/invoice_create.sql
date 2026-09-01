-- button on a /person page to make a new empty invoice for this person
create function stork.invoice_create(_pid integer,
	out head text, out body text) as $$
declare
	invid integer;
begin
	insert into invoices (person_id) values ($1) returning id into invid;
	head = e'303\r\nLocation: /invoice/' || invid;
end;
$$ language plpgsql;

