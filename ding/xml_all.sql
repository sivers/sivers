-- copying the items subquery from xml_articles, xml_ebooks, xml_interviews, xml_tweets
--
-- limit first in the subquery, then order the final
--
-- item types will be interspersed, since final order by date not type

create function ding.xml_all(out xml text) as $$
begin
	xml = o.template('atom', (select to_jsonb(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		lat.max_updated as updated,
		('https://' || f.link) as link,
		lat.items
		from feeds f
		left join lateral (
			select max(r1.updated) as max_updated,
			json_agg(r1) as items from (
			(
				--- ARTICLES:
				select ('https://sive.rs/' || uri) as id,
				title,
				o.rfc3339(posted) as published,
				o.rfc3339(posted) as updated,
				('https://sive.rs/' || uri) as link,
				translate((regexp_matches(original, E'(^|\n)\t([^\n]*)'))[2], '<>', '') as summary,
				replace(original, 'href="/', 'href="https://sive.rs/') as content
				from articles
				where posted < now()
				order by posted desc limit 25
			) union all (
				--- TWEETS:
				select ('https://sive.rs/d/' || i.id) as id,
				i.message as title,
				o.rfc3339(time) as published,
				o.rfc3339(time) as updated,
				('https://sive.rs/d/' || i.id) as link,
				message as summary,
				('<p>' || o.hyperlink(message) || '</p>') as content
				from tweets i
				where i.time < now()
				order by time desc limit 25
			) union all (
				--- EBOOKS:
				select ('https://sive.rs/book/' || code) as id,
				(title || ' - by ' || author) as title,
				o.rfc3339(read) as published,
				o.rfc3339(read) as updated,
				('https://sive.rs/book/' || code) as link,
				summary,
				(
					'<h2>summary:</h2><p>' || summary || '</p>' ||
					'<h2>recommend: ' || rating || '/10</h2>' || 
					'<img src="https://sive.rs/images/book/' || code || '.webp">' ||
					'<h2>my notes:</h2>' || (
						select string_agg('<p>' || ebooknotes.note || '</p>',
							'' order by ebooknotes.sortid)
						from ebooknotes
						where ebook_code = ebooks.code
					)
				) as content
				from ebooks
				where read is not null and rating is not null and summary is not null
				order by read desc limit 25
			) union all (
				--- INTERVIEWS:
				select ('https://sive.rs/' || uri) as id,
				case when name = host then name else name || ' by '|| host end as title,
				o.rfc3339(ymdhm) as published,
				o.rfc3339(ymdhm) as updated,
				('https://sive.rs/' || uri) as link,
				summary,
				('<p>' || summary || '</p>') as content
				from interviews
				where uri is not null and summary is not null
				order by ymdhm desc limit 25
			)
			order by updated desc limit 100
			) r1
		) lat on true
		where f.uri = 'sive.rs/feed.xml'
	) r));
end;
$$ language plpgsql;

