create function o.feeds() returns table (uri text, rss text) as $$
	with q as (
		select feed_uri, max(pubdate) as latest
		from feeditems
		where pubdate < now()
		group by feed_uri
	)
	update feeds
	set updated_at = q.latest
	from q
	where feeds.uri = q.feed_uri
	and feeds.updated_at < q.latest
	returning feeds.uri, o.feed(feeds.uri) as rss
$$ language sql;

