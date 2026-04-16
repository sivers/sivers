-- sive.rs/i.rss postcast of interviews: RSS 2.0 
create function ding.xml_i(out xml text) as $$
	select o.template('rss2-podcast', (select to_jsonb(r) from (
		select ('https://' || f.uri) as uri,
		('https://' || f.link) as link,
		f.title,
		f.description,
		('https://' || f.imageurl) as imageurl,
		(select o.rfc822(max(interviews.ymdhm))
			from interviews
			join media on media.interview = interviews.id
			where interviews.uri is not null
			and interviews.summary is not null
			and media.audio is not null
		) as pubDate,
		(select json_agg(r1) from (
			select ('https://sive.rs/' || interviews.uri) as link,
			case when interviews.name = host then name else name || ' by '|| host end as title,
			summary as description,
			('<p>' || summary || '</p>') as content,
			o.rfc822(ymdhm) as pubDate,
			('https://m.sive.rs/' || audios.filename) as mediaurl,
			audios.bytes,
			audios.seconds
			from interviews
			join media on media.interview = interviews.id
			join audios on media.audio = audios.id
			order by interviews.ymdhm desc
		) r1) as items
		from feeds f
		where f.uri = 'sive.rs/i.rss'
	) r));
$$ language sql;
