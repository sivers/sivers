create or replace function stork.invoice_update(_id integer, _nu json,
	out head text, out body text) as $$
begin
	-- long list of columns that should be null instead of '' (empty)
	perform o.update_black('invoices', $1, $2, '{id,person_id,created,shipcost,total,code}',
	'{paydate,payinfo,shipinfo,shipname,addr1,addr2,city,state,postcode,country,phone,gift_note}');
	head = e'303\r\nLocation: /invoice/' || $1;
end;
$$ language plpgsql;
