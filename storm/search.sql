create function storm.search(kki char(32), term text,
	out head text, out body text) as $$
declare
	admin integer;
	q text;
	ps jsonb;
begin
	-- first, web app auth
	select admin_auths.person_id into admin
	from logins
	join admin_auths on logins.person_id = admin_auths.person_id
	where logins.cookie = $1
	and admin_auths.appcode = 'storm';
	if admin is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;
	-- turn the search term into a '%thing like this%'
	term = btrim($2, e'\t\r\n ');
	q = concat('%', term , '%');
	-- now search with that new ilike search term
	ps = coalesce((select json_agg(r) from (
		select people.id, people.name,
		string_agg(ats.email, ',') as emails
		from people
		left join ats on people.id = ats.person_id
		where (people.name ilike q or company ilike q or ats.email ilike q)
		and people.id in (
			select person_id from invoices
		)
		group by people.id, people.name
		order by people.name, people.id
	) r), '[]');
	body = o.template('storm-wrap', 'storm-search', jsonb_build_object(
		'term', term, 'people', ps
	));
end;
$$ language plpgsql;

