-- one CSV row per physical lineitem
-- listing column names manually here to get the correct order
-- (could be more elegant getting keys from JSONB but then wrong order)
create function stork.preship_csv(out head text, out body text) as $$
declare
	cols text[] = '{howmany,item_id,sku,quantity,invid,paydate,shipcost,person_id,shipname,addr1,addr2,city,state,postcode,country,phone,email,stuff,gift,gift_note}';
	r jsonb;
	col text;
	fields text[];
	val text;
begin
	head = e'Content-Type: text/csv; charset=utf-8\r\nContent-Disposition: attachment; filename="preship.csv"';
	body = array_to_string(cols, ',') || e'\r\n';
	for r in select value from jsonb_array_elements(stork.preship()) loop
		fields = '{}';
		foreach col in array cols loop
			val = r ->> col;
			fields = array_append(fields, case when val is null then '' else '"' || replace(val, '"', '""') || '"' end);
		end loop;
		body = body || array_to_string(fields, ',') || e'\r\n';
	end loop;
end;
$$ language plpgsql;
