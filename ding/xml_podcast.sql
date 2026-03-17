-- RSS 2.0 not Atom!
create function ding.xml_podcast(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as uri,
		('https://' || f.link) as link,
		f.title,
		f.description,
		('https://' || f.imageurl) as imageurl,
		(select o.rfc822(max(articles.posted))
			from articles
			join media on media.article = articles.id
			join audios on media.audio = audios.id
		) as pubDate,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/' || articles.uri) as link,
			articles.title,
			btrim(regexp_replace(regexp_replace( -- strip HTML and \n\r\t
				articles.original,
			'<[^>]+>', '', 'g'), '\s+', ' ', 'g')) as description,
			replace(articles.original, 'href="/', 'href="https://sive.rs/') as content,
			o.rfc822(articles.posted) as pubDate,
			('https://m.sive.rs/' || audios.filename) as mediaurl,
			audios.bytes,
			audios.seconds
			from articles
			join media on media.article = articles.id
			join audios on media.audio = audios.id
			order by articles.posted desc
			limit 100
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/podcast.rss'
	) r;
	xml = o.template('rss2-podcast', data);
end;
$$ language plpgsql;

