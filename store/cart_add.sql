-- cart text format "item_id-quantity,item_id-quantity" (example: '10-1,30-2')
-- given the existing text cart lineitems, add new item at quantity if available
-- return updated text cart
-- "sorter" ordinality added to sort cart with new item at bottom (sorter=99)
create function store.cart_add(_item integer, _quantity integer, _cart text)
returns text as $$
	with nu as (
		-- parse the incoming params and cart
		select 
		split_part(elem, '-', 1)::integer as item_id,
		split_part(elem, '-', 2)::integer as quantity,
		sorter
		from unnest(string_to_array(_cart, ',')) with ordinality as t(elem, sorter)
		where elem ~ '^\d+-\d+$'
		union all
		select _item, _quantity, 99
		where _item is not null and _quantity is not null and _quantity > 0
	),
	goods as (
		-- only valid and available items (if items.weight 0 then 1 is max quantity)
		select nu.item_id,
		case when items.weight = 0 then 1 else sum(nu.quantity) end as quantity,
		min(nu.sorter) as sorter
		from nu
		join items on nu.item_id = items.id
		where items.available is true
		group by nu.item_id, items.weight
	)
	select coalesce(string_agg(item_id || '-' || quantity, ',' order by sorter), '')
	from goods;
$$ language sql stable;

