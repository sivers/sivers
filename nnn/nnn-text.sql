create function nnn.text(out body text) as $$
declare
	r record;
begin
	body = e'name\tcity\tstate\tcountry\tcreated\tupdated\tchecked\turl\n';
	for r in
		select
			people.name,
			people.city,
			people.state,
			people.country,
			now_pages.created_at as created,
			now_pages.updated_at as updated,
			now_pages.checked_at as checked,
			now_pages.long as url
		from now_pages
		join people on now_pages.person_id = people.id
		order by now_pages.created_at, people.name
	loop
		body = body
			|| coalesce(r.name, '')	 || e'\t'
			|| coalesce(r.city, '')	 || e'\t'
			|| coalesce(r.state, '')	|| e'\t'
			|| coalesce(r.country, '')  || e'\t'
			|| r.created::text || e'\t'
			|| r.updated::text || e'\t'
			|| r.checked::text || e'\t'
			|| coalesce(r.url, '')	  || e'\n';
	end loop;
end;
$$ language plpgsql;
