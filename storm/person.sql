create function storm.person(_id integer,
	out head text, out body text) as $$
declare
	data jsonb;
begin
	data = to_jsonb(r) from (
		select people.id, people.name,
		string_agg(ats.email, ',') as emails,
		coalesce((select jsonb_agg(z) from (
			select id, status, paydate,
			o.show_money(currency, total) as show_total,
			coalesce((select jsonb_agg(ll) from (
				select items.name, lineitems.quantity,
				o.show_money(invoices.currency, lineitems.price) as show_price
				from lineitems
				join items on lineitems.item_id = items.id
				where lineitems.invoice_id = invoices.id
				order by lineitems.item_id
			) ll), '[]') as lineitems
			from invoices
			where person_id = $1
			order by id desc
		) z), '[]') as invoices
		from people
		left join ats on people.id = ats.person_id
		where people.id = $1
		group by people.id, people.name
	) r;
	if data is null then
		head = e'303\r\nLocation: /';
	else
		body = o.template('storm-wrap', 'storm-person', data);
	end if;
end;
$$ language plpgsql;

