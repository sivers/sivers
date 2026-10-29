-- "ipcc" = "IP → Country & Currency"
-- INPUT: IP address
-- OUTPUT:
--   country: 'NZ' -- country code, (not found? 'US')
--   country_name: 'New Zealand'    (not found? 'U.S.A.')
--   currency: 'NZD' -- code (not found or unsupported? 'USD')
--   currency_name: 'New Zealand Dollar'
create function o.ipcc(_ip inet,
	out country char(2), out country_name text, out currency char(3), out currency_name text)
as $$
begin
	select ips.country into ipcc.country
	from ips
	where range @> ($1 - '0.0.0.0'::inet);
	-- if country was found then...
	if ipcc.country is not null then
		-- get country name, if any
		select name into ipcc.country_name
		from countries
		where code = ipcc.country;
	else -- not found? shouldn't happen. default US to avoid null
		ipcc.country = 'US';
		ipcc.country_name = 'U.S.A.';
	end if;
	-- now what currency (in my table) goes with that? (USD backup)
	select coalesce((
		select c.currency
		from country_currency c
		where c.country = ipcc.country
	), 'USD') into ipcc.currency;
	-- get currency name
	select name into ipcc.currency_name from currencies where code = ipcc.currency;
end;
$$ language plpgsql;

