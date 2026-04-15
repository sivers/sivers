create function me.articles_tagged(_tag text, out body text) as $$
	select o.template('me-wrap', 'me-articles', jsonb_build_object(
		'pagetitle', 'Derek Sivers ' || $1 || ' articles',
		'tag', $1,
		'howmany', (
			select count(*)
			from articles  -- same query as below
			join atags on articles.id = atags.article_id
			where atags.tag = $1
			and posted is not null and posted <= now()
		),
		'articles', (select jsonb_agg(r) from (
			select uri, posted as ymd, title
			from articles
			join atags on articles.id = atags.article_id
			where atags.tag = $1
			and posted is not null and posted <= now()
			order by posted desc nulls last, id desc
		) r)
	));
$$ language sql;

