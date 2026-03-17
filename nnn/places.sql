-- the name, url, and count(# of pages) for each place
-- this query used by two others:
-- 1. nnn.placespage() to make the single HTML index of all places
-- 2. nnn.placesout() return URI and HTML to write each place page
create function nnn.places()
returns table (country char(2), state text, name text, url text, count integer) as $$
	select  -- these (US/CA/GB/AU) group & count by states
	people.country, people.state,
	concat(people.country, ': ', states.name) as name,
	concat(people.country, '-', people.state) as url,
	count(*)
	from people
	join states on (people.country = states.country and people.state = states.code)
	where id in (select id from now_profiles)
	and people.country in ('US', 'CA', 'GB', 'AU')
	group by people.country, people.state, states.name
	union
	select  -- all others group & count by country
	people.country, null,  -- state not used in query that uses this
	countries.name,
	people.country as url,
	count(*)
	from people
	join countries on people.country = countries.code
	where id in (select id from now_profiles)
	and country not in ('US', 'CA', 'GB', 'AU')
	group by people.country, countries.name
	order by count desc, country asc
$$ language sql;
