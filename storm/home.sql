create function storm.home(
	out head text, out body text) as $$
begin
	body = o.template('storm-wrap', 'storm-home', jsonb_build_object(
	'problem', (select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) from (
		select invoices.id, people.name, paydate, o.show_money(currency, total)
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status = 'problem'
		order by invoices.id
	) t),
	'ship', (select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) from (
		select invoices.id, people.name, paydate, o.show_money(currency, total)
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status = 'ship'
		order by invoices.id
	) t),
	'wait', (select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) from (
		select invoices.id, people.name, paydate, o.show_money(currency, total)
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status = 'wait'
		order by invoices.id
	) t),
	'done', (select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) from (
		select invoices.id, people.name, paydate, o.show_money(currency, total)
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status = 'done'
		order by invoices.id 
		limit 50
	) t)));
end;
$$ language plpgsql;

