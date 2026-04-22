create function me.articles(out body text) as $$
	select o.template('me-wrap', 'me-articles', jsonb_build_object(
		'pagetitle', 'Derek Sivers articles',
		'topics', me.topics(),
		'howmany', (select count(*) from articles)
	));
$$ language sql;
