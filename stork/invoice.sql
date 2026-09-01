-- the main page to edit an invoice

create or replace function stork.invoice(_id integer,
	out head text, out body text) as $$
begin
	body = o.template('stork-wrap', 'stork-invoice', (select to_jsonb(r) from (
		select invoices.*, -- see invoices table for column names
		countries.name as country_name, -- show country for clarity
		people.name, o.email_for(person_id) as email, -- person info
		coalesce((select jsonb_agg(s) from ( -- lineitems
			select lineitems.id, items.name, quantity, lineitems.price
			from lineitems
			join items on lineitems.item_id = items.id
			where invoice_id = invoices.id
			order by lineitems.id
		) s), '[]') as lineitems,
		(select jsonb_agg(i) from (
			select id, name
			from items
			where available is true
			order by id
		) i) as allitems, -- all items for pulldown to add
		'["cart", "ship", "wait", "problem", "done"]'::jsonb as allstatuses -- all statuses for editing invoices.status
		from invoices
		join people on invoices.person_id = people.id
		left join countries on invoices.country = countries.code
		where invoices.id = $1
	) r));
end;
$$ language plpgsql;
