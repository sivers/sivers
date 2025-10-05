-- search results
-- now_profiles.public_id, people.name, now_profiles.title, now_profiles.photo
create function nnn.search(_q text,
	out head text, out body text) as $$
declare
	q text;
	url text;
	tmp jsonb;
	data jsonb;
begin
	-- normalize: trim, lowercase, whitelist a-z, 0-9, - . ' and space
	q = regexp_replace(lower(btrim($1)), '[^a-z0-9\-\.'' ]', '', 'g');

	-- minimum 3 chars
	if $1 is null or length(q) < 3 then
		head = e'303\r\nLocation: /';
		return;
	end if;

	-- if it matches country or state name, jump to that page
	select places.url into url
	from nnn.places()
	join countries on places.country = countries.code
	left join states on (places.country = states.country and places.state = states.code)
		-- there's no /US or /GB or /AU or /CA since only state-pages
	where (lower(countries.name) = q and places.country not in ('AU', 'CA', 'GB', 'US'))
	or lower(states.name) = q
	limit 1;
	if url is not null then
		head = e'303\r\nLocation: /' || url;
		return;
	end if;

	-- return cleaned q to show what was searched
	data = jsonb_build_object('q', q, 'pagetitle', 'search nownownow.com');

	-- name
	execute $sql$ select jsonb_agg(r) from (
		select n.public_id, people.name, n.title, n.photo
		from now_profiles n
		join people on n.id = people.id
		where lower(people.name) like $1
		order by people.name -- arbitrary
	) r $sql$
	into tmp
	using '%' || q || '%';
	if tmp is not null then
		data = data || jsonb_build_object('name', tmp);
		tmp = null;
	end if;

	-- city
	execute $sql$ select jsonb_agg(r) from (
		select n.public_id, people.name, n.title, n.photo
		from now_profiles n
		join people on n.id = people.id
		where lower(people.city) like $1
		order by n.public_id -- arbitrary
	) r $sql$
	into tmp
	using '%' || q || '%';
	if tmp is not null then
		data = data || jsonb_build_object('city', tmp);
		tmp = null;
	end if;

	-- answers
	execute $sql$ select jsonb_agg(r) from (
		select n.public_id, people.name, n.title, n.photo
		from now_profiles n
		join people on n.id = people.id
		where lower(n.title) like $1
		or lower(n.liner) like $1
		or lower(n.why) like $1
		or lower(n.thought) like $1
		or lower(n.red) like $1
		order by n.public_id -- arbitrary
	) r $sql$
	into tmp
	using '%' || q || '%';
	if tmp is not null then
		data = data || jsonb_build_object('answers', tmp);
		tmp = null;
	end if;

	-- none? (2 keys init) save the template some logic using 'none' key
	if (select count(*) from jsonb_object_keys(data)) = 2 then
		data = data || jsonb_build_object('none', 'none');
	end if;

	body = o.template('nnn-wrap', 'nnn-search', data);
end;
$$ language plpgsql;

