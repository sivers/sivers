-- used in both /home and /articles
create function me.topics() returns jsonb as $$
	select jsonb_agg(r) from (
		select topics.uri, topics.name, topics.description, metabooks.uri as isbook
		from topics
		left join metabooks on topics.uri = metabooks.uri
		order by topics.sortid
	) r
$$ language sql;

