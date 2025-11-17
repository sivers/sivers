-- shipments (invoices.status = 'ship') shown with CSV download link
create function storm.shipments(kki char(32),
	out head text, out body text) as $$
declare
	admin integer;
	lines jsonb;
begin
	-- first, web app auth
	select admin_auths.person_id into admin
	from logins
	join admin_auths on logins.person_id = admin_auths.person_id
	where logins.cookie = $1
	and admin_auths.appcode = 'storm';
	if admin is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;
	-- grouped in a weird way with each item in an order on its own line
	lines = coalesce((select json_agg(r) from (
		with grouped as (
			select person_id, count(*) as howmany
			from invoices
			where status = 'ship'
			group by person_id
		), contents as (
			select invoices.id, (select string_agg(r.sku || '=' || r.quantity, ',') as stuff from (
				select items.sku, lineitems.quantity
				from lineitems
				join items on lineitems.item_id = items.id
				where lineitems.invoice_id = invoices.id
				and items.weight > 0
				order by items.id
			) r)
			from invoices
			where invoices.status = 'ship'
		)
		select grouped.howmany, lineitems.item_id, items.sku, lineitems.quantity,
		invoices.id as invid, invoices.paydate, invoices.shipcost, invoices.person_id,
		invoices.shipname, invoices.addr1, invoices.addr2, invoices.city,
		invoices.state, invoices.postcode, invoices.country, invoices.phone,
		o.email_for(people.id) as email, contents.stuff,
		case position('WRAP' in items.sku) when 0 then 'no' else 'yes' end as gift,
		invoices.gift_note
		from lineitems
		join items on lineitems.item_id = items.id
		join invoices on lineitems.invoice_id = invoices.id
		join grouped on invoices.person_id = grouped.person_id
		join contents on invoices.id = contents.id
		join people on invoices.person_id = people.id
		where invoices.status = 'ship'
		and items.weight > 0
		order by invoices.person_id, invoices.id, lineitems.item_id
	) r), '[]');
	body = o.template('storm-wrap', 'storm-shipments', jsonb_build_object(
		'lines', lines
	));
end;
$$ language plpgsql;

