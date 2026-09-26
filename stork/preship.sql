-- what physical books are waiting to be shipped?
-- used by both preship_see.sql and preship_csv.sql 
-- COLUMNS:
-- howmany
-- item_id
-- sku
-- quantity
-- invid
-- paydate
-- shipcost
-- person_id
-- shipname
-- addr1
-- addr2
-- city
-- state
-- postcode
-- country
-- phone
-- email
-- stuff
-- gift
-- gift_note
create or replace function stork.preship() returns jsonb as $$
	select coalesce(jsonb_agg(a order by a.person_id, a.invid, a.item_id), '[]'::jsonb) from (
		with grouped as (
			select person_id, count(*) as howmany
			from invoices
			where status = 'ship'
			group by person_id
		), contents as (
			select invoices.id,
			string_agg(items.sku || '=' || lineitems.quantity, ', ' order by items.id) as stuff
			from invoices
			join lineitems on lineitems.invoice_id = invoices.id
			join items on lineitems.item_id = items.id
			where invoices.status = 'ship'
			and items.weight > 0
			group by invoices.id
		)
		select grouped.howmany, lineitems.item_id, items.sku, lineitems.quantity,
		invoices.id as invid, invoices.paydate, invoices.shipcost, invoices.person_id,
		invoices.shipname, invoices.addr1, invoices.addr2, invoices.city,
		invoices.state, invoices.postcode, invoices.country, invoices.phone,
		o.email_for(invoices.person_id) as email, contents.stuff,
		case position('WRAP' in items.sku) when 0 then 'no' else 'yes' end as gift,
		invoices.gift_note
		from lineitems
		join items on lineitems.item_id = items.id
		join invoices on lineitems.invoice_id = invoices.id
		join grouped on invoices.person_id = grouped.person_id
		join contents on invoices.id = contents.id
		where invoices.status = 'ship'
		and items.weight > 0
	) a;
$$ language sql;
