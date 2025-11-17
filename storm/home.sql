-- home page shows reports: problems, newest, sales summary
create function storm.home(kki char(32),
	out head text, out body text) as $$
declare
	admin integer;
	problems jsonb;
	newest jsonb;
	salesum jsonb;
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
	-- orders with problem status
	problems = coalesce((select json_agg(r) from (
		select invoices.id, invoices.person_id, people.name,
		invoices.created, invoices.paydate, invoices.status,
		invoices.currency, invoices.total
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status in ('problem', 'hold', 'wait')
		order by status, id
	) r), '[]');
	-- newest invoices not in other status
	newest = json_agg(r) from (
		select invoices.id, invoices.person_id, people.name,
		invoices.created, invoices.paydate, invoices.status,
		invoices.currency, invoices.total
		from invoices
		join people on invoices.person_id = people.id
		where invoices.status not in ('cart', 'problem', 'hold', 'wait')
		order by invoices.id desc
		limit 500
	) r;
	-- sales per item
	salesum = json_agg(r) from (
		select items.id, items.name, sum(lineitems.quantity)
		from lineitems
		join items on lineitems.item_id = items.id
		join invoices on lineitems.invoice_id = invoices.id
		where invoices.status != 'cart'
		group by items.id, items.name
		order by items.id
	) r;
	body = o.template('storm-wrap', 'storm-home', jsonb_build_object(
		'problems', problems, 'newest', newest, 'salesum', salesum
	));
end;
$$ language plpgsql;

