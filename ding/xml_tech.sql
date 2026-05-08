-- SAME AS xml_articles() but only topic='tech' to match sive.rs/tech
-- o.template function is escaping HTML
-- the regexp as summary is getting the first line that starts with a tab
-- and make all relative links full links for content
create function ding.xml_tech(out xml text) as $$
	select o.template('atom', (select to_jsonb(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		(select o.rfc3339(max(posted)) from articles where topic = 'tech') as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/' || uri) as id,
			title,
			o.rfc3339(posted) as published,
			o.rfc3339(posted) as updated,
			('https://sive.rs/' || uri) as link,
			regexp_replace((regexp_matches(original, E'(^|\n)\t([^\n]*)'))[2], '<[^>]*>', '', 'g') as summary,
			replace(original, 'href="/', 'href="https://sive.rs/') as content
			from articles
			where topic = 'tech'
			order by posted desc
			limit 50
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/tech.xml'
	) r));
$$ language sql;

