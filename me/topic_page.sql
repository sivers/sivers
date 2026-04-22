create function me.topic_page(_topic text, out body text) as $$
	select o.template('me-wrap', 'me-topic', (select jsonb_build_object(
		'pagetitle', 'Derek Sivers ' || name || ' articles',
		'name', name,
		'description', description,
		'howmany', (select count(*) from articles where topic = $1),
		'articles', (select jsonb_agg(r) from (
			select uri, posted as ymd, title
			from articles
			where topic = $1
			and posted is not null
			order by posted desc, id desc
		) r)
	) from topics where uri = $1));
$$ language sql;
