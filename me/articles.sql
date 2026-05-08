create function me.articles(out body text) as $$
	select o.template('me-wrap', 'me-articles', jsonb_build_object(
		'pagetitle', 'Derek Sivers articles',
		'newest', (select jsonb_agg(r) from (
			select uri, posted as ymd, title
			from articles
			order by posted desc
			limit 5
		) r),
		'topics', me.topics(),
		'howmany', (select count(*) from articles)
	));
$$ language sql;
