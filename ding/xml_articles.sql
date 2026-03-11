-- o.template function is escaping HTML
-- the regexp as summary is getting the first line that starts with a tab
-- and make all relative links full links for content
create function ding.xml_articles(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		(select o.rfc3339(max(posted)) from posts) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/' || posts.uri) as id,
			articles.title,
			o.rfc3339(posts.posted) as published,
			o.rfc3339(posts.posted) as updated,
			('https://sive.rs/' || posts.uri) as link,
			translate((regexp_matches(original, E'(^|\n)\t([^\n]*)'))[2], '<>', '') as summary,
			replace(articles.original, 'href="/', 'href="https://sive.rs/') as content
			from articles
			join posts on posts.article_id = articles.id
			where posts.posted < now()
			order by posts.posted desc
			limit 50
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/articles.xml'
	) r;
	xml = o.template('atom', data);
end;
$$ language plpgsql;

