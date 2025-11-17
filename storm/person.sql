-- person's info and their invoices
create function storm.person(kki char(32), pid integer,
	out head text, out body text) as $$
declare
	admin integer;
	person jsonb;
	ivs jsonb;
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
	-- get the person info (or leave if none)
	person = row_to_json(r) from (
		select people.id, people.name,
		string_agg(ats.email, ',') as emails
		from people
		left join ats on people.id = ats.person_id
		where people.id = $2
		group by people.id, people.name
	) r;
	if person is null then
		head = e'303\r\nLocation: /';
		return;
	end if;
	-- now their invoices
	ivs = coalesce((select json_agg(z) from (
		select id, created, status, paydate, currency, total,
		coalesce((select json_agg(r1) from (
			select l.id, l.item_id, i.name, l.quantity, l.price
			from lineitems l
			join items i on l.item_id = i.id
			where l.invoice_id = invoices.id
			order by l.id
		) r1), '[]') as lineitems
		from invoices
		where person_id = $2
		order by invoices.id
	) z), '[]');
	body = o.template('storm-wrap', 'storm-person', jsonb_build_object(
		'person', person, 'invoices', ivs
	));
end;
$$ language plpgsql;

