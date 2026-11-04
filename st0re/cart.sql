-- cart text format "item_id-quantity,item_id-quantity" (example: '10-1,30-2')
-- cart has already been cleaned and validated before this function, so trust
-- big SQL creates JSONB, given as 2nd arg to o.template which returns HTML text
create function st0re.cart(_country char(2), _currency char(3), _cart text)
returns text as $$
select o.template('st0re-cart', (
	with ins as ( -- inputs from function arguments:
		select _cart as cart_str, _currency::text as cc, _country::text as co
	),
	rc as ( -- raw cart:
		select
			t.sorter,
			split_part(t.elem, '-', 1)::smallint as item_id,
			split_part(t.elem, '-', 2)::smallint as quantity,
			ins.cc, -- passed through for o.show_money
			lower(ins.cc) as curr
		from ins,
		unnest(string_to_array(ins.cart_str, ',')) with ordinality as t(elem, sorter)
	),
	calc as ( -- price calculations:
		select
			rc.sorter,
			rc.item_id,
			rc.quantity,
			rc.cc,
			items.name,
			items.weight,
			-- base item price
			(rc.quantity * (to_jsonb(ip) ->> rc.curr)::numeric) 
			+ 
			-- plus metaitem price only if it's the 1st occurrence of this metaitem in the cart
			case 
				when row_number() over (partition by items.metaitem_id order by rc.sorter) = 1 
				then (to_jsonb(mp) ->> rc.curr)::numeric 
				else 0 
			end as line_price
		from rc
		join items on rc.item_id = items.id
		join prices ip on items.price_id = ip.id
		join metaitems on items.metaitem_id = metaitems.id
		join prices mp on metaitems.price_id = mp.id
	),
	lines as ( -- formatted lineitems:
		select 
			sorter,
			item_id,
			quantity,
			weight,
			case when weight = 0 then
				o.select1(to_jsonb(array[0,1]::text[]), quantity::text)
			else
				o.select1(to_jsonb(array[0,1,2,3,4,5,10,20,25,30]::text[]), quantity::text)
			end as quantopts,
			name,
			line_price,
			o.show_money(cc, line_price) as show_price
		from calc
	),
	agg as ( -- aggregate subtotal, weight, and lineitems:
		select 
			coalesce(sum(line_price), 0) as subtotal,
			coalesce(sum(quantity * weight)::integer, 0) as book_count,
			jsonb_agg(to_jsonb(lines) - 'sorter' - 'weight' order by sorter) as lineitems
		from lines
	),
	ship as ( -- calculate shipping cost by integer division (full boxes) and modulo (remainder):
		select case when agg.book_count <= 0 or ins.co is null then 0 else round(
			((agg.book_count / mb.max_books) * o.money2(mb.currency, mb.amount, ins.cc))
			+ coalesce(o.money2(rem.currency, rem.amount, ins.cc), 0),
		currencies.round2) end as shipcost
		from ins
		cross join agg
		join currencies on currencies.code = ins.cc
		left join postzones on postzones.warehouse = 'US' and postzones.country = ins.co
		left join lateral (
			select books as max_books, currency, amount
			from postrates
			where zone = postzones.zone
			order by books desc
			limit 1
		) mb on true
		left join postrates rem on rem.zone = postzones.zone and rem.books = (agg.book_count % mb.max_books)
	)
	select jsonb_build_object(
		'cc', ins.cc,
		'currency', currencies.name,
		'currencies', o.select1((select jsonb_agg(c) from (select code, name from currencies order by name) c), ins.cc),
		'countries', o.select_country(ins.co),
		'subtotal', agg.subtotal,
		'show_subtotal', o.show_money(ins.cc, agg.subtotal),
		'shipcost', ship.shipcost,
		'show_shipcost', o.show_money(ins.cc, ship.shipcost),
		'total', agg.subtotal + ship.shipcost,
		'show_total', o.show_money(ins.cc, agg.subtotal + ship.shipcost),
		'lineitems', agg.lineitems
	) as cart_json
	from ins
	join currencies on ins.cc = currencies.code
	cross join agg
	cross join ship
));
$$ language sql stable;
