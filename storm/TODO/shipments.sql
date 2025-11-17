	js = coalesce((select json_agg(r) from (
		with grouped as (
			select person_id, count(*) as howmany
			from invoices
			where status = 'ship'
			and warehouse = $1
			group by person_id
		), contents as (
			select invoices.id, (select json_agg(r) as stuff from (
				select items.sku, lineitems.quantity
				from lineitems
				join items on lineitems.item_id = items.id
				where lineitems.invoice_id = invoices.id
				and items.weight > 0
				order by items.id
			) r)
			from invoices
			where invoices.status = 'ship'
			and warehouse = $1
		)
		select grouped.howmany, lineitems.item_id, items.sku, lineitems.quantity,
		invoices.id as invid, invoices.paydate, invoices.shipcost, invoices.person_id,
		invoices.shipname, invoices.addr1, invoices.addr2, invoices.city,
		invoices.state, invoices.postcode, invoices.country, invoices.phone,
		f.email_for(people.id) as email, contents.stuff,
		case position('WRAP' in items.sku) when 0 then 'no' else 'yes' end as gift,
		invoices.gift_note
		from lineitems
		join items on lineitems.item_id = items.id
		join invoices on lineitems.invoice_id = invoices.id
		join grouped on invoices.person_id = grouped.person_id
		join contents on invoices.id = contents.id
		join people on invoices.person_id = people.id
		where invoices.status = 'ship'
		and warehouse = $1
		and items.weight > 0
		order by invoices.person_id, invoices.id, lineitems.item_id
	) r), '[]');
