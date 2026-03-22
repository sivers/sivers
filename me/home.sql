create function me.home(out body text) as $$
declare
	articles jsonb;
	tweets jsonb;
	books jsonb;
begin
	select jsonb_agg(r) into articles from (
		select uri, posted as ymd, title
		from articles
		where posted is not null and posted <= now()
		order by posted desc nulls last, id desc
	) r;

	select jsonb_agg(r) into tweets from (
		select time::date as ymd, message as tweet
		from tweets
		where article_id is null and time <= now()
		order by time desc nulls last
		limit 20
	) r;

	select jsonb_agg(r) into books from (
		select read as ymd,
		('book/' || code) as uri,
		(title || ' - by ' || author) as title
		from ebooks
		where read is not null and summary is not null
		order by read desc nulls last
	) r;

	body = o.template('me-wrap', 'me-home', jsonb_build_object(
		'pagetitle', 'Derek Sivers',
		'articles', articles,
		'tweets', tweets,
		'books', books
	));
end;
$$ language plpgsql;

