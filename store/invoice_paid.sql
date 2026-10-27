-- NOTE: no function "store.invoice_paid": either invoice_id_paid or invoice_code_paid (used by Stripe)

-- mark invoice as paid by setting payment = total and saving payinfo
create or replace function store.invoice_id_paid(_invid integer, _payinfo text) returns integer as $$
declare
	a record;
	li record;
	body text = '';
begin
	update invoices
	set paydate = now(),
	payment = total,
	payinfo = $2,
        status = (case when store.invoice_is_physical($1) then 'ship' else 'done' end)
	where id = $1
	and paydate is null;
	if not found then
		return null;
	else
		select invoices.*, people.name into a
		from invoices join people on invoices.person_id = people.id
		where invoices.id = $1;
		body = concat(body, 'Thanks! Download your ebooks and audiobooks at https://sivers.com/e?t={temp}', e'\n\n');
		body = concat(body, 'Your receipt:', e'\n');
		body = concat(body, e'\n', 'Order #: ', a.id, ' / ', a.person_id);
		body = concat(body, e'\n', 'By: ', a.name, ' <', o.email_for(a.person_id), '>');
		body = concat(body, e'\n\n');
		for li in
			select lineitems.id, item_id, items.name, quantity, lineitems.price
			from lineitems
			join items on lineitems.item_id = items.id
			where invoice_id = $1 loop
			if li.quantity > 1 then
				body = concat(body, li.quantity, ' copies of ');
			end if;
			body = concat(body, li.name);
			body = concat(body, ' for ', o.show_money(a.currency, li.price));
			body = concat(body, e'\n');
		end loop;
		if a.shipcost > 0 then
			body = concat(body, e'\n', 'Shipping: ', o.show_money(a.currency, a.shipcost));
		end if;
		body = concat(body, e'\n', 'Total: ', o.show_money(a.currency, a.total));
		if a.shipcost > 0 then
			body = concat(body, e'\n\n', 'I will email again when it has shipped.');
			body = concat(body, e'\n\n', 'Sending to:');
			body = concat(body, e'\nName: ', a.shipname);
			body = concat(body, e'\nAddress line 1: ', a.addr1);
			body = concat(body, e'\nAddress line 2: ', a.addr2);
			body = concat(body, e'\nCity: ', a.city);
			body = concat(body, e'\nState: ', a.state);
			body = concat(body, e'\nPostcode: ', a.postcode);
			body = concat(body, e'\nCountry: ', a.country);
		end if;
		perform o.email(0, a.person_id, concat('Sivers order #', $1), body, null);
		return $1;
	end if;
end;
$$ language plpgsql;

create function store.invoice_code_paid(_code char(8), _payinfo text) returns integer as $$
	select * from store.invoice_id_paid((
		select id from invoices where code = $1
	), $2);
$$ language sql;
