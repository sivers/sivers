create function me.home(out body text) as $$
	select o.template('me-wrap', 'me-home', jsonb_build_object(
		'pagetitle', 'Derek Sivers',
		'newest', (select jsonb_agg(r) from (
			select uri, posted as ymd, title
			from articles
			order by posted desc
			limit 5
		) r),
		'tweets', (select jsonb_agg(t) from (
			select time::date as ymd, o.hyperlink(replace(message, '&', '&amp;')) as tweet
			from tweets
			order by time desc
			limit 5
		) t),
		'topics', me.topics()
	));
$$ language sql;

