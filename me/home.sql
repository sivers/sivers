create function me.home(out body text) as $$
	select o.template('me-wrap', 'me-home', jsonb_build_object(
		'pagetitle', 'Derek Sivers',
		'topics', me.topics(),
		'tweets', (select jsonb_agg(r1) from (
			select time::date as ymd, o.hyperlink(message) as tweet
			from tweets
			where article_id is null and time <= now()
			order by time desc nulls last
			limit 20
		) r1),
		'books', (select jsonb_agg(r2) from (
			select code as uri, read as ymd,
			(title || ' - by ' || author) as title
			from ebooks
			where code in (select me.book_uris())
			order by read desc nulls last
		) r2)
	));
$$ language sql;

