-- XML elements name lowercase unless quoted like "pubDate"
create or replace function o.feed(_uri text, out xml text) as $$
declare
	f feeds;
	i record;
begin
	select * into f from feeds where uri = $1;
	if f is null then
		return;
	end if;
	xml = '<?xml version="1.0"?><rss version="2.0"><channel>';
	xml = xml || xmlelement(name title, f.title);
	xml = xml || xmlelement(name link, 'https://' || f.link);
	xml = xml || xmlelement(name description, f.description);
	xml = xml || xmlelement(name language, 'en-us');
	xml = xml || xmlelement(name "lastBuildDate", o.rfc822(f.updated_at));
	xml = xml || xmlelement(name "pubDate", o.rfc822(f.updated_at));
	xml = xml || xmlelement(name ttl, '1440'); -- cache in minutes
	for i in
		select * from feeditems
		where feed_uri = $1
		order by pubdate desc, uri desc
	loop
	xml = xml || xmlelement(name item,
		xmlelement(name title, i.title),
		xmlelement(name guid, xmlattributes('true' AS "isPermaLink"), 'https://' || i.uri),
		xmlelement(name link, 'https://' || i.uri),
		xmlelement(name author, 'Derek Sivers'),
		xmlelement(name category, f.category), -- feeds.category
		xmlelement(name "pubDate", o.rfc822(i.pubdate))
	);
	end loop;
	xml = xml || '</channel></rss>';
	-- linebreaks make it easier to test, but aren't necessary
	xml = regexp_replace(xml, '><', e'>\n<', 'g');
end;
$$ language plpgsql;

