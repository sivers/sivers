-- all profiles! returns table not value. loop through results to write to disk
create function nnn.profiles() returns table (uri char(4), body text) as $$
begin
	return query
	select r.public_id as uri,
	o.template('nnn-wrap', 'nnn-profile', to_jsonb(r)) as body
	from (
		select people.name || ' now' as pagetitle,
		now_profiles.public_id, now_profiles.title, liner, why, thought, red,
		people.name, people.city,
		-- if country & statecode in states table, use name of state. else as-is
		coalesce(states.name, people.state) as state,
		countries.name as country,
		coalesce((select jsonb_agg(r1) from (
			select long, short from now_pages where person_id = people.id
		) r1), '[]') as pages,
		coalesce((select jsonb_agg(r2) from (
			select url from urls
			where person_id = people.id
			order by main desc nulls last, id asc
		) r2), '[]') as websites
		from now_profiles
		join people on now_profiles.id = people.id
		join countries on people.country = countries.code
		left join states on (people.country = states.country and people.state = states.code)
		where now_profiles.photo is true
		order by now_profiles.public_id
	) r;
end;
$$ language plpgsql;

