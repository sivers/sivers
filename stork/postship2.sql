-- Warehouse downloaded CSV from preship_csv.sql then shipped those items.
-- Now they need to tell us which invoices have been shipped, with what tracking info.
-- So they upload a different CSV with just invoice_id and shipinfo.
-- column 1: invoice_ids
-- invoice_id might be more than one! two invoices can be combined into one shipment
-- format: "123" or "123-124", so split invoice_id by "-" and loop through integers
-- column 2: shipinfo 
-- format: single line of text (tracking# like "987A654B4321" or "RL123NL456")
--
-- TWO STAGES:
--
-- 1. They upload CSV into form at postship1 with a "verify" submit button.
--    Router calls this function with $2(verify) = true
--    Parse CSV into JSONB and display data via "stork-postship2" HTML template.
--
-- 2. They look at it and post with a "done" button that posts CSV again.
--    Router calls this function with $2(verify) = false
--    Parse CSV and for each invoice, set status='done', shipdate=now(), shipinfo from the uploaded row
create function stork.postship2(_csv text, verify boolean,
	out head text, out body text) as $$
declare
	shipments jsonb = '[]'; -- uploaded invoices.id => shipinfo
	-- temporary vars for building or using shipments:
	line text;
	fields text[];
	ids text;
	info text;
	invid text;
	r record;
begin
	-- generic CSV parser:
	-- 2 fields per line, optionally quoted, doubled quotes unescaped
	for line in select regexp_split_to_table($1, e'\r\n|\n|\r') loop
		if btrim(line) = '' then
			continue;
		end if;
		fields = regexp_match(line,
			'^(?:"((?:[^"]|"")*)"|([^",]*)),(?:"((?:[^"]|"")*)"|([^",]*))$');
		if fields is null then
			raise exception 'Expected invoice_ids,shipinfo: %', line;
		end if;
		ids = btrim(coalesce(replace(fields[1], '""', '"'), fields[2]));
		info = coalesce(replace(fields[3], '""', '"'), fields[4]);
		-- skip header row
		if ids = 'invoice_ids' and info = 'shipinfo' then
			continue;
		end if;
		foreach invid in array string_to_array(ids, '-') loop
			shipments = shipments || jsonb_build_array(jsonb_build_object(
				'invoice_id', invid::integer, 'shipinfo', info));
		end loop;
	end loop;
	if verify is true then
		body = o.template('stork-wrap', 'stork-postship2',
			jsonb_build_object('shipments', shipments, 'csv', $1));
	else
		for r in select * from jsonb_to_recordset(shipments)
			as x(invoice_id integer, shipinfo text) loop
			update invoices
			set status = 'done', shipdate = current_date, shipinfo = r.shipinfo
			where id = r.invoice_id and status != 'done';
			-- TODO: EMAIL CUSTOMER
		end loop;
		head = e'303\r\nLocation: /';
	end if;
end;
$$ language plpgsql;
