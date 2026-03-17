-- Update prices in lineitems and invoice.
-- (terminology in subqueries below: "live" = dynamic calcuation query)
-- 1. lineitems.price = invoices.currency: items.price_id * lineitems.quantity
-- 2. invoices.shipcost = done inside o.shipcost(invoice_id)
-- 3. invoices.total = sum(lineitems.price) + invoices.shipcost
create function o.invoice_reprice(_invid integer) returns void as $$
begin
	-- STEP 0: PHYSICAL NEEDS WAREHOUSE. UPDATE IF NULL.
	-- warehouse should be set in store flow, so probably never needed
	perform 1 from invoices where id = $1
	and o.invoice_is_physical(id) is true
	and warehouse is null;
	if found then
		update invoices set warehouse = 'US' where id = $1;
	end if;
	-- STEP 1: REPRICE LINEITEMS
	with live as (
		select nu.*
		from o.lineitems_liveprices($1) nu
		join lineitems on nu.lineitem_id = lineitems.id
	)
	update lineitems
	set price = live.liveprice
	from live
	where lineitems.id = live.lineitem_id;
	-- STEP 2: REPRICE SHIPCOST
	with live as (
		select o.shipcost($1)
	)
	update invoices
	set shipcost = live.shipcost
	from live
	where invoices.id = $1;
	-- STEP 3: UPDATE TOTAL: (sum(lineitems) + shipcost)
	with live as (select (
		select coalesce(sum(lineitems.price), 0)
		from lineitems
		where invoice_id = invoices.id)
		+ o.shipcost(invoices.id)
		as total
		from invoices where id = $1
	)
	update invoices
	set total = live.total
	from live
	where invoices.id = $1;
end;
$$ language plpgsql;
