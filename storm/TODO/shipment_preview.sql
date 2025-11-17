	js = row_to_json(r) from (
		select invoices.id, invoices.status, invoices.shipdate, invoices.country, (
		select json_agg(s) as stuff from (
			select lineitems.quantity, items.name
			from lineitems
			join items on lineitems.item_id = items.id
			where lineitems.invoice_id = $1
			and items.weight > 0
		) s)
		from invoices
		where invoices.id = $1
	) r;
