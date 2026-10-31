-- given the existing text cart lineitems, add new item at quantity if available
-- return updated text cart
create function store.cart_add(_item integer, _quantity integer, _cart text)
returns text as $$
	with nu as (
		-- incoming parsed cart and new item-quantity
		select 
		split_part(elem, '-', 1)::integer as item_id,
		split_part(elem, '-', 2)::integer as quantity,
		ordinality
		from unnest(string_to_array(nullif(trim(_cart), ''), ',')) with ordinality as elem
		where elem ~ '^\d+-\d+$'
		union all
		select _item, _quantity, 99 -- (99 = ordinality to put new at end of _cart)
		where _item is not null and _quantity is not null and _quantity > 0
	),
	goodlines as (
		-- validate items and sum quantities (if items.weight 0 then 1 is max quantity)
		select nu.item_id,
		case when items.weight = 0 then 1 else sum(nu.quantity) end as quantity,
		min(nu.ordinality) as ix
		from nu
		join items on nu.item_id = items.id
		where items.available is true
		group by nu.item_id, items.weight
		having sum(nu.quantity) > 0 -- only items with quantity > 0
	)
	select coalesce(string_agg(item_id || '-' || quantity, ',' order by ix), '')
	from goodlines;
$$ language sql stable;

