-- linebreaks make it easier to test, but aren't necessary
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
	xml = e'<?xml version="1.0"?>\n<rss version="2.0">\n<channel>\n';
	xml = xml || xmlelement(name title, f.title) || e'\n';
	xml = xml || xmlelement(name link, 'https://' || f.link) || e'\n';
	xml = xml || xmlelement(name description, f.description) || e'\n';
	for i in
		select * from feeditems
		where feed_uri = $1
		order by pubdate desc, uri desc
	loop
		xml = xml || xmlelement(name item,
			xmlelement(name title, i.title),
			xmlelement(name "pubDate", to_char(i.pubdate at time zone 'UTC', 'Dy, DD Mon YYYY HH24:MI:SS "GMT"'))
		) || e'\n';
	end loop;
	xml = xml || e'</channel>\n</rss>';
end;
$$ language plpgsql;

