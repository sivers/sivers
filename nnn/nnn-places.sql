-- use URLs to write the place pages
create function nnn.places(out body text, out urls text[]) as $$
declare
	places jsonb;
begin
	select jsonb_agg(r) into places from (
		select  -- these (US/CA/GB/AU) group & count by states
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
		countries.name,
		country as url,
		count(*)
		from people
		join countries on people.country = countries.code
		where id in (select id from now_profiles)
		and country not in ('US', 'CA', 'GB', 'AU')
		group by country, countries.name
		order by count desc
	) r;
	-- use URLs to write the place pages
	select array_agg(x->>'url' order by x->>'url') into urls
	from jsonb_array_elements(places) x;
	body = o.template('nnn-wrap', 'nnn-home', jsonb_build_object(
		'pagetitle', 'personal websites with a /now page',
		'date', current_date,
		'places', places));
end;
$$ language plpgsql;
