-- o.template function is escaping HTML
-- the regexp as summary is getting the first line that starts with a tab
-- and make all relative links full links for content
create function ding.xml_ebooks(out xml text) as $$
declare
	data jsonb;
begin
	data = row_to_json(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		(select o.rfc3339(max(read)) from ebooks
			where read is not null and rating is not null and summary is not null
		) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
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
			order by read desc
			limit 50
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/book.xml'
	) r;
	xml = o.template('atom', data);
end;
$$ language plpgsql;

