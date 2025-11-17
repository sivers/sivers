	pid integer;
	whaus char(2);
	tocountry char(2);
	tracking text;
	subj text;
	body text;
begin
	select person_id, warehouse, country, shipinfo
	into pid, whaus, tocountry, tracking
	from invoices
	where id = $1;
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
	-- from which warehouse?
	if whaus = 'DE' then
		body = subj || e' from Münster Germany to:\n\n';
	else
		body = subj || e' from North Carolina to:\n\n';
	end if;

	-- address:
	select shipname, addr1, addr2, city, state, postcode,
		invoices.country, countries.name as countryname,
		invoices.phone
	into r
	from invoices
	join countries on invoices.country = countries.code
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
		if whaus = 'DE' then
			body = body || 'https://www.mydhli.com/global-en/home/tracking.html?tracking-id=' || tracking;
		elsif whaus = 'US' and substring(tracking, 1, 2) = '1Z' then
			body = body || 'https://wwwapps.ups.com/WebTracking/processRequest?tracknum=' || tracking;
		elsif whaus = 'US' and tocountry = 'US' then
			body = body || 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=' || tracking;
		elsif whaus = 'US' then
			body = body || 'https://www.goglobalpost.com/track-detail/?t=' || tracking;
		end if;
		body = body || e'\n(It might not show activity until tomorrow.)\n';
	end if;

	-- closing:
	body = body || e'\nREMINDER: You get all digital formats like audiobook and e-book included forever! Just go to:\n\nhttps://sivers.com/\n\n... and log in with this email address (' || f.emails(pid) || e') any time on any device.  This is order# ' || $1 || '.';

