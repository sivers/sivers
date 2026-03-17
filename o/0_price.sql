-- given currency and prices.id, return numeric price
create function o.price(_currency char(3), _price_id smallint, out price numeric) as $$
begin
	if $1 is null or $2 is null or $2 = 0 then
		price = 0;
	else
		execute format('select %I from prices where id = $1', lower($1))
		into price using $2;
	end if;
end;
$$ language plpgsql;

-- given only currency, return MAXIMUM numeric price for that currency
create function o.price(_currency char(3), out price numeric) as $$
begin
	execute format(
		'select max(%I) from prices', lower($1)
	)
	into price;
end;
$$ language plpgsql;
