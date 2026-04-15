create function me.tweets(out body text) as $$
	select o.template('me-wrap', 'me-tweets', jsonb_build_object(
		'pagetitle', 'Derek Sivers tweets, microposts',
		'tweets', (select jsonb_agg(r) from (
			select time::date as ymd, o.hyperlink(replace(message, '&', '&amp;')) as tweet
			from tweets
			where article_id is null and time <= now()
			order by time desc nulls last
		) r)
	));
$$ language sql;

