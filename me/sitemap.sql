-- I was hoping to use the *_uris() functions here
-- but since they only have the URIs and I also need the lastmod dates
-- I instead just duplicated their 'where' conditions. Maybe unwise.
--
-- NOTE: 2026-04-12 is the day I relaunched the whole site
create function me.sitemap(out body text) as $$
declare
	r record;
begin
	body = '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url><loc>https://sive.rs/</loc><lastmod>' || current_date || '</lastmod></url>
';
	for r in select uri
		from me.pages()
		order by uri
		loop
		body = body || '<url><loc>https://sive.rs/' || r.uri || e'</loc><lastmod>2026-04-12</lastmod></url>\n';
	end loop;
	for r in select uri, greatest(posted, '2026-04-12'::date) as posted
		from articles
		where posted is not null
		and posted <= now()
		order by posted desc
		loop
		body = body || '<url><loc>https://sive.rs/' || r.uri || '</loc><lastmod>' || r.posted || e'</lastmod></url>\n';
	end loop;
	for r in select code, greatest(read, '2026-04-12'::date) as read
		from ebooks
		where read is not null
		and rating is not null
		and summary is not null
		order by read desc
		loop
		body = body || '<url><loc>https://sive.rs/book/' || r.code || '</loc><lastmod>' || r.read || e'</lastmod></url>\n';
	end loop;
	for r in select uri, greatest(ymdhm::date, '2026-04-12'::date) as ymd
		from interviews
		where uri is not null
		and summary is not null
		order by ymdhm desc
		loop
		body = body || '<url><loc>https://sive.rs/' || r.uri || '</loc><lastmod>' || r.ymd || e'</lastmod></url>\n';
	end loop;
	for r in select where_id, greatest(max(whatime)::date, '2026-04-12'::date) as lastmod
		from meetings
		where whatime < now()
		and topics is not null
		group by where_id
		order by where_id
		loop
		body = body || '<url><loc>https://sive.rs/met/at-' || r.where_id || '</loc><lastmod>' || r.lastmod || e'</lastmod></url>\n';
	end loop;
	for r in select id, greatest(whatime::date, '2026-04-12'::date) as lastmod
		from meetings
		where whatime < now()
		and topics is not null
		order by id
		loop
		body = body || '<url><loc>https://sive.rs/met/' || r.id || '</loc><lastmod>' || r.lastmod || e'</lastmod></url>\n';
	end loop;
	for r in select uri
		from presentations
		order by month desc
		loop
		body = body || '<url><loc>https://sive.rs/' || r.uri || e'</loc><lastmod>2026-04-12</lastmod></url>\n';
	end loop;
	body = body || '</urlset>';
end;
$$ language plpgsql;

