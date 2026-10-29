-- "ipccsave" = "IP → Country & Currency → SAVE"
-- INPUT: person_id and their current IP address
-- OUTPUT:
--   country: 'NZ' -- country code, (not found? null)
--   country_name: 'New Zealand'    (not found? null)
--   currency: 'NZD' -- code (not found or unsupported? 'USD')
--   currency_name: 'New Zealand Dollar'
create function o.ipccsave(_pid integer, _ip inet,
	out country char(2), out country_name text, out currency char(3), out currency_name text)
as $$
begin
	-- first see if country code is cached in stats from the past month
	select statvalue into ipccsave.country from stats
	where person_id = $1
	and statkey = 'country'
	and created_at > now() - interval '30 days';
	-- if not, look up this IP address
	if ipccsave.country is null then
		select ips.country into ipccsave.country
		from ips
		where range @> ($2 - '0.0.0.0'::inet);
	end if;
	-- if country was found then...
	if ipccsave.country is not null then
		-- cache it for next time:
		insert into stats (person_id, statkey, statvalue)
		values ($1, 'country', ipccsave.country);
		-- get country name, if any
		select name into ipccsave.country_name
		from countries
		where code = ipccsave.country;
	end if;
	-- now what currency goes with that?
	select coalesce((
		select c.currency
		from country_currency c
		where c.country = ipccsave.country
	), 'USD') into ipccsave.currency;
	-- get currency name
	select name into ipccsave.currency_name from currencies where code = ipccsave.currency;
end;
$$ language plpgsql;

create or replace function o.ipccsave(_pid integer, _ip inet,
	out country char(2), out country_name text, out currency char(3), out currency_name text)
as $$
begin
	-- first see if country code is cached in stats from the past month
	select countries.code,
		countries.name,
		coalesce(country_currency.currency, 'USD'),
		currencies.name
	into ipccsave.country,
		ipccsave.country_name,
		ipccsave.currency,
		ipccsave.currency_name
	from stats
	join countries on stats.statvalue = countries.code
	left join country_currency on stats.statvalue = country_currency.country
	join currencies on coalesce(country_currency.currency, 'USD') = currencies.code
	where person_id = $1
	and statkey = 'country'
	and created_at > now() - interval '30 days';
	-- if not, get it anew from IP address
	if ipccsave.country is null then
		select * into ipccsave.country,
			ipccsave.country_name,
			ipccsave.currency,
			ipccsave.currency_name
		from o.ipcc($2);
		-- cache it for next time:
		insert into stats (person_id, statkey, statvalue)
		values ($1, 'country', ipccsave.country);
	end if;
end;
$$ language plpgsql;

