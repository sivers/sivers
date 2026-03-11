-- RSS 2.0 not Atom!
create function ding.xml_podcast(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as uri,
		'Derek Sivers' as creator,
		f.category,
		('https://' || f.link) as link,
		f.title,
		f.description,
		f.keywords,
		('https://' || f.imageurl) as imageurl,
		o.rfc822(f.updated_at) as pubDate,
		f.ttl,
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
			left join articles a on i.article = a.id
			where i.feed_uri = f.uri
			and i.pubdate < now()
			order by i.pubdate desc
			limit 100
		) r1), '[]') as items
		from feeds f
		where f.uri = $1
	) r;
	xml = o.template('rss2-podcast', data);
end;
$$ language plpgsql;

