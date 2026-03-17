create function ding.xml_nownownow(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle, (
			select o.rfc3339(max(updated_at)) from now_pages
		) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select now_pages.long as id,
			(people.name || ' in ' || people.city || ', ' || countries.name) as title,
			o.rfc3339(now_pages.created_at) as published,
			o.rfc3339(now_pages.updated_at) as updated,
			now_pages.long as link,
			now_pages.short as summary,
			('<p><a href="' || now_pages.long || '">' || now_pages.short || '</a></p>') as content
			from now_pages
			join people on now_pages.person_id = people.id
			join countries on people.country = countries.code
			order by now_pages.updated_at desc, now_pages.id desc
			limit 50
		) r1), '[]') as items
		from feeds f
		where f.uri = 'nownownow.com/feed.xml'
	) r;
	xml = o.template('atom', data);
end;
$$ language plpgsql;

