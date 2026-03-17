-- given country code, and state (often NULL), return HTML
create function nnn.place(_country char(2), _state text, out body text) as $$
declare
	placename text;  --also pagetitle
	pids integer[];  --people in this place
	profiles1 jsonb; --public_id, name, title, pages:[{long, short}]
	profiles2 jsonb; --public_id, name, pages:[{long, short}]
	profiles3 jsonb; --name, title, pages:[{long, short}]
	profiles4 jsonb; --name, pages:[{long, short}]
	data jsonb;
begin
	if $2 is null then
		-- ids of people with now_pages in this country
		select array(
			select person_id
			from now_pages
			join people on now_pages.person_id = people.id
			where people.country = $1
		) into pids;
		-- placename like Singapore
		select name into placename from countries where code = $1;
	else
		-- ids of people with now_pages in this country and state
		select array(
			select person_id
			from now_pages
			join people on now_pages.person_id = people.id
			where people.country = $1
			and people.state = $2
		) into pids;
		-- placename like Victoria, Australia
		select concat(states.name, ', ', countries.name) into placename
		from states
		join countries on states.country = countries.code
		where states.country = $1
		and states.code = $2;
	end if;
	-- profiles that have a photo and all questions answered
	profiles1 = coalesce((select jsonb_agg(r) from (
		select people.name, now_profiles.public_id, now_profiles.title,
		coalesce((select json_agg(r1) from (
			select long, short
			from now_pages
			where now_pages.person_id = now_profiles.id
			order by now_pages.id
		) r1), '[]') as pages
		from now_profiles
		join people on now_profiles.id = people.id
		where now_profiles.id = any(pids)
		and photo is true
		and length(title) > 0
		and length(liner) > 0
		and length(why) > 0
		and length(thought) > 0
		and length(red) > 0
		order by people.id desc
	) r), '[]');
	-- profiles that have a photo but NOT all questions answered
	profiles2 = coalesce((select jsonb_agg(r) from (
		select people.name, now_profiles.public_id,
		coalesce((select json_agg(r1) from (
			select long, short
			from now_pages
			where now_pages.person_id = now_profiles.id
			order by now_pages.id
		) r1), '[]') as pages
		from now_profiles
		join people on now_profiles.id = people.id
		where now_profiles.id = any(pids)
		and photo is true and (
			title is null or title = ''
			or liner is null or liner = ''
			or why is null or why = ''
			or thought is null or thought = ''
			or red is null or red = ''
		)
		order by people.id desc
	) r), '[]');
	-- profiles that LACK a photo but all questions answered
	profiles3 = coalesce((select jsonb_agg(r) from (
		select people.name, now_profiles.public_id, now_profiles.title,
		coalesce((select json_agg(r1) from (
			select long, short
			from now_pages
			where now_pages.person_id = now_profiles.id
			order by now_pages.id
		) r1), '[]') as pages
		from now_profiles
		join people on now_profiles.id = people.id
		where now_profiles.id = any(pids)
		and photo is false
		and length(title) > 0
		and length(liner) > 0
		and length(why) > 0
		and length(thought) > 0
		and length(red) > 0
		order by people.id desc
	) r), '[]');
	-- profiles that LACK a photo and NOT all questions answered
	profiles4 = coalesce((select jsonb_agg(r) from (
		select people.name, now_profiles.public_id,
		coalesce((select json_agg(r1) from (
			select long, short
			from now_pages
			where now_pages.person_id = now_profiles.id
			order by now_pages.id
		) r1), '[]') as pages
		from now_profiles
		join people on now_profiles.id = people.id
		where now_profiles.id = any(pids)
		and photo is false and (
			title is null or title = ''
			or liner is null or liner = ''
			or why is null or why = ''
			or thought is null or thought = ''
			or red is null or red = ''
		)
		order by people.id desc
	) r), '[]');
	data = jsonb_build_object(
		'placename', placename,
		'pagetitle', '/now pages in ' || placename,
		'date', current_date,
		'profiles1', profiles1,
		'profiles2', profiles2,
		'profiles3', profiles3,
		'profiles4', profiles4
	);
	body = o.template('nnn-wrap', 'nnn-place', data);
end;
$$ language plpgsql;
