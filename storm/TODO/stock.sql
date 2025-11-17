	js = coalesce((select json_agg(r) from (
		select stock.*, items.name, items.sku
		from stock
		join items on stock.item = items.id
		order by stock.warehouse desc, stock.item asc
	) r), '[]');
