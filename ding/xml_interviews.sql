-- notice the title logic
create function ding.xml_interviews(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle, (
			select o.rfc3339(max(ymdhm)) from interviews
			where uri is not null and summary is not null
		) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/' || uri) as id,
			case when name = host then name else name || ' by '|| host end as title,
			o.rfc3339(ymdhm) as published,
			o.rfc3339(ymdhm) as updated,
			('https://sive.rs/' || uri) as link,
			summary,
			('<p>' || summary || '</p>') as content
			from interviews
			where uri is not null and summary is not null
			order by ymdhm desc
			limit 50
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/i.xml'
	) r;
	xml = o.template('atom', data);
end;
$$ language plpgsql;

