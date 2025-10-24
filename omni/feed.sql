create function o.feed(_uri text, out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as uri,
		'Derek Sivers' as creator,
		f.category,
		f.podcast,
		('https://' || f.link) as link,
		f.title,
		f.description,
		f.keywords,
		('https://' || f.imageurl) as imageurl,
		o.rfc822(f.updated_at) as pubDate,
		'1440' as ttl, -- minutes to cache feed
		coalesce((select json_agg(r1) from (
			select ('https://' || i.uri) as link,
			coalesce(a.title, i.title) as title,
			btrim(regexp_replace(regexp_replace( -- strip HTML and \n\r\t
				coalesce(a.original, i.content),
			'<[^>]+>', '', 'g'), '\s+', ' ', 'g')) as description,
			coalesce(a.original, i.content) as content,
			o.rfc822(i.pubdate) as pubDate,
			('https://' || i.mediaurl) as mediaurl,
			i.bytes,
			i.seconds
			from feeditems i
			left join articles a on i.article_id = a.id
			where i.feed_uri = f.uri
			order by i.pubdate desc
		) r1), '[]') as items
		from feeds f
		where f.uri = $1
	) r;
	if data ->> 'podcast' = 'true' then
		xml = o.template('feed-podcast', data);
	else
		xml = o.template('feed', data);
	end if;
end;
$$ language plpgsql;

