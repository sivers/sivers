-- Return new live prices for the lineitems in this invoice.
-- Use for updating after change.
-- IMPORTANT: uses currency of invoice, returning numeric in that currency
create function o.lineitems_liveprices(_invid integer)
returns table (lineitem_id integer, liveprice numeric) as $$
	with metapaid as (
		select * from o.access_paid((
			select person_id from invoices where id = $1
	)))
	select lineitems.id,
	-- now use that lineitems.id for checking whether to add metaitems.price
	(o.price(invoices.currency, items.price_id) * lineitems.quantity) + (
		-- check whether to add metaitems.price
		case when lineitems.id in (select lineitem_id from metapaid)
		then o.price(invoices.currency, metaitems.price_id) else 0 end
	) liveprice
	from invoices
	join lineitems on invoices.id = lineitems.invoice_id
	join items on lineitems.item_id = items.id
	join metaitems on items.metaitem_id = metaitems.id
	where invoices.id = $1
	order by lineitems.id;
$$ language sql;
