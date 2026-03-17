-- o.template function is escaping HTML
create function ding.xml_tweets(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		(select o.rfc3339(max(time)) from tweets) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/d/' || i.id) as id,
			i.message as title,
			o.rfc3339(time) as published,
			o.rfc3339(time) as updated,
			('https://sive.rs/d/' || i.id) as link,
			message as summary,
			('<p>' || o.hyperlink(message) || '</p>') as content
			from tweets i
			where i.time < now()
			order by i.id desc
			limit 100
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/d.xml'
	) r;
	xml = o.template('atom', data);
end;
$$ language plpgsql;

