-- show one invoice
create function storm.invoice(kki char(32), invid integer,
	out head text, out body text) as $$
declare
	admin integer;
	iv jsonb;
	li jsonb;
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
	-- get invoice
	iv = row_to_json(r) from (
		select invoices.*, people.name
		from invoices
		join people on invoices.person_id = people.id
		where invoices.id = $2
	) r;
	if iv is null then
		head = e'303\r\nLocation: /';
		return;
	end if;
	-- lineitems
	li = coalesce((select json_agg(r) from (
		select lineitems.*, items.name
		from lineitems
		join items on lineitems.item_id = items.id
		where invoice_id = $2
	) r), '[]');
	body = o.template('storm-wrap', 'storm-invoice', jsonb_build_object(
		'invoice', iv, 'lineitems', li
	));
end;
$$ language plpgsql;

