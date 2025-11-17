	js = coalesce((select json_agg(r) from (
		select * from view_invoice
		where status in ('problem', 'hold', 'wait')
		and warehouse = $1
		order by status, id
	) r), '[]');
