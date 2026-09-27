-- create and send email confirmation of shipped book
-- returns emails.id of the inserted email
create function stork.postship_email(_invid integer,
	out email_id integer) as $$
declare
	r record;
	pid integer;
	tocountry char(2);
	tracking text;
	subj text;
	body text;
begin
	select person_id, country, shipinfo
	into pid, tocountry, tracking
	from invoices
	where id = $1
	and store.invoice_is_physical($1) is true;
	if not found then
		raise 'not found';
	end if;

	-- subject differs with plural vs not
	select case when sum(lineitems.quantity) > 1 then
		'Your books began their journey'
	else
		'Your book began its journey'
	end into subj
	from lineitems
	join items on lineitems.item_id = items.id
	where lineitems.invoice_id = $1
	and items.weight > 0;

	-- begin building email body:
	body = subj || e' from North Carolina to:\n\n';

	-- address with extra precautions to avoid null although it should never happen
	select
	coalesce(shipname, '') as shipname,
	coalesce(addr1, '') as addr1,
	coalesce(addr2, '') as addr2,
	coalesce(city, '') as city,
	coalesce(state, '') as state,
	coalesce(postcode, '') as postcode,
	coalesce(invoices.country, '') as country,
	coalesce(countries.name, '') as countryname,
	coalesce(invoices.phone, '') as phone
	into r
	from invoices
	left join countries on invoices.country = countries.code
	where invoices.id = $1;
	body = body || r.shipname || e'\n' || r.addr1 || e'\n';
 	if r.addr2 is not null and length(r.addr2) > 0 then
		body = body || r.addr2 || e'\n';
 	end if;
 	if r.country = 'US' then
		body = body || r.city || ', ' || r.state || ' ' || r.postcode;
 	else
		body = body || r.city || e'\n';
 		if r.state is not null and length(r.state) > 0 then
			body = body || r.state || e'\n';
		end if;
 		if r.postcode is not null and length(r.postcode) > 0 then
			body = body || r.postcode || e'\n';
		end if;
		body = body || r.countryname;
	end if;
	if r.phone is not null and length(r.phone) > 0 then
		body = body || e'\nphone: ' || r.phone;
	end if;

	-- contents:
	body = body || e'\n\nYou should receive:\n';
	for r in
		select lineitems.quantity, items.name
		from lineitems
		join items on lineitems.item_id = items.id
		where lineitems.invoice_id = $1
		and items.weight > 0
	loop
		body = body || r.quantity || ' × ' || r.name || e'\n';
	end loop;
	-- has autographed book in it?
	perform 1 from lineitems where invoice_id = $1 and item_id in (13, 23, 33, 43, 53);
	if found then
		body = body || e'NOTE: I signed the autographed book in the last few pages at the END of the book.\n';
	end if;

	-- tracking
	if tocountry is not null and tracking is not null and length(tracking) > 0 then
		body = body || e'\nTrack the package here:\n';
		if substring(tracking, 1, 2) = '1Z' then
			body = body || 'https://wwwapps.ups.com/WebTracking/processRequest?tracknum=' || tracking;
		elsif tocountry = 'US' then
			body = body || 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=' || tracking;
		else
			body = body || 'https://www.goglobalpost.com/track-detail/?t=' || tracking;
		end if;
		body = body || e'\n(It might not show activity until tomorrow.)\n';
	end if;

	-- closing:
	body = body || e'\nREMINDER: You get all digital formats like audiobook and e-book included forever! Just go to:\n\nhttps://sivers.com/\n\n... and log in with this email address (' || o.email_for(pid) || ') any time on any device.  This is order# ' || $1 || '.';

	-- insert the email, (sent by listen/notify), returning the id it returns
	select o.email(0, pid, subj, body, null) into email_id;
end;
$$ language plpgsql;

