-- mark invoice as shipped (then email them)
create function storm.invoice_ship(_invid integer, _shipinfo text,
	-- only add tracking ("shipinfo") if exists
	if length(btrim($2)) > 1 then
		update invoices
		set status = 'done', shipdate = now(), shipinfo = $2
		where id = $1
		and status != 'done';
	else
		update invoices
		set status = 'done', shipdate = now()
		where id = $1
		and status != 'done';
	end if;
		select x.ok, x.js into ok, js from storm.invoice_email($1) x;
