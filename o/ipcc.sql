-- "ipcc" = "IP → Country & Currency"
-- INPUT: person_id and their current IP address
-- OUTPUT:
--   country: 'NZ' -- country code, (not found? 'XX')
--   country_name: 'New Zealand'    (not found? null)
--   currency: 'NZD' -- code (not found or unsupported? 'USD')
--   currency_name: 'New Zealand Dollar'
create function o.ipcc(_pid integer, _ip inet,
	out country char(2), out country_name text, out currency char(3), out currency_name text)
as $$
begin
	-- first see if country code is cached in stats from the past month
	-- (assuming lookup from ips is slower than stats)
	select statvalue into ipcc.country from stats
	where person_id = $1
	and statkey = 'country'
	and created_at > now() - interval '30 days';
	-- if not, look up this IP address in ipinfo, 'XX' if not found
	if country is null then
		select coalesce((
			select ips.country from ips
			where ip1 <= $2
			and ip2 >= $2
		), 'XX') into ipcc.country;
	end if;
	-- if country was found then...
	if ipcc.country != 'XX' then
		-- cache it for next time:
		insert into stats (person_id, statkey, statvalue)
		values ($1, 'country', ipcc.country);
		-- get country name, if any
		select name into ipcc.country_name
		from countries
		where code = ipcc.country;
	end if;
	-- now what currency goes with that?
	select coalesce((
		select c.currency
		from country_currency c
		where c.country = ipcc.country
	), 'USD') into ipcc.currency;
	-- get currency name
	select name into ipcc.currency_name from currencies where code = ipcc.currency;
end;
$$ language plpgsql;

