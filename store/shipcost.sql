-- Calculate shipping cost of this invoice, returned in the invoice's currency.
-- If quantity higher than postrates knows, split into smaller boxes and combine.
create function store.shipcost(_invid integer) returns numeric as $$
declare
	invoice record;
	book_count integer;
	zone_id integer;
	box_size integer;
	box_cost numeric;
	total_cost numeric;
begin
	-- cache this invoice info into invoice record (or stop now if not found)
	select invoices.currency, invoices.warehouse, invoices.country, currencies.round2
	into invoice
	from invoices
	join currencies on currencies.code = invoices.currency
	where invoices.id = $1;
	if not found then
		return null;
	end if;

	-- weight either 1 if physical or 0 if digital, times quantity = total
	select sum(lineitems.quantity * items.weight)::integer into book_count
	from lineitems
	join items on items.id = lineitems.item_id
	where lineitems.invoice_id = $1;

	-- no shipping charge without destination, warehouse, or physical items
	if invoice.warehouse is null or invoice.country is null or coalesce(book_count, 0) <= 0 then
		return 0;
	end if;

	-- fail hard if this warehouse can't ship to that country
	select zone into zone_id from postzones
	where warehouse = invoice.warehouse and country = invoice.country;
	if not found then
		raise exception 'country not in postzones: %', invoice.country;
	end if;

	-- return shipcost now if it's in postrates
	select o.money2(currency, amount, invoice.currency) into total_cost
	from postrates where zone = zone_id and books = book_count;
	if total_cost is not null then
		return round(total_cost, invoice.round2);
	end if;

	-- too big for previous step? split! what's the biggest box size there?
	select postrates.books, o.money2(currency, amount, invoice.currency)
	into box_size, box_cost
	from postrates where zone = zone_id
	order by postrates.books desc limit 1;
	-- what?!? nothing? freak out!
	if box_size is null or box_size <= 0 or book_count <= box_size then
		return null;
	end if;

	-- boxes * cost + remainder * cost, and life is going to be fine
	total_cost = (book_count / box_size) * box_cost;
	book_count = book_count % box_size;
	if book_count > 0 then
		select o.money2(currency, amount, invoice.currency) into box_cost
		from postrates where zone = zone_id and books = book_count;
		total_cost = total_cost + box_cost;
	end if;

	return round(total_cost, invoice.round2);
end;
$$ language plpgsql;

