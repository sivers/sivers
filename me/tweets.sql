create function me.tweets(out body text) as $$
	select o.template('me-wrap', 'me-tweets', jsonb_build_object(
		'pagetitle', 'Derek Sivers tweets, microposts',
		'tweets', (select jsonb_agg(r) from (
			select time::date as ymd, o.hyperlink(replace(message, '&', '&amp;')) as tweet
			from tweets
			order by time desc
		) r)
	));
$$ language sql;

