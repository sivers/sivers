-- For the purpose of charging them once and only once for the metaitem,
-- find the first occurrence of them buying or having it.
-- Order by paid invoices first, then lineitems.id.
create function o.access_paid(_pid integer)
returns table (metaitem_id smallint, lineitem_id integer) as $$
	with q1 as (
		select lineitems.id, items.metaitem_id, rank() over (
			partition by items.metaitem_id
			order by invoices.paydate nulls last, lineitems.id
		)
		from invoices
		join lineitems on invoices.id = lineitems.invoice_id
		join items on lineitems.item_id = items.id
		where invoices.person_id = $1
	)
	select metaitem_id, id as lineitem_id
	from q1
	where rank = 1
	order by metaitem_id;
$$ language sql;
