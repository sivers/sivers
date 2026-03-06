create function ding.atom(_feeduri text, out atom xml) as $$
	-- get then process entries' data using coalesce to bring in info from joined tables
	with entries as (
		select
		'https://' || feeditems.uri as id,
		coalesce(articles.title, feeditems.title) as title,
		to_char(pubdate at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as published,
		to_char(pubdate at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as updated,
		'https://' || uri as link,
		regexp_replace(coalesce(feeditems.content, articles.original), '<[^>]*>', '', 'g') as summary, 
		concat('<h1>', coalesce(articles.title, feeditems.title), '</h1>', 
			coalesce(feeditems.content, articles.original)
		) as content
		from feeditems
		left join articles on feeditems.article = articles.id
		where feed_uri = $1
	),
	-- convert those entries (above) to xml for the bottom query to include
	xmlinfo as (
		select xmlagg(xmlelement(
			name entry,
			xmlforest(
				e.id,
				e.title,
				e.published,
				e.updated
			),
			xmlelement(name link, xmlattributes('alternate' as rel, 'text/html' as type, e.link as href)),
			xmlelement(name summary, xmlattributes('text' as type), e.summary),
			xmlelement(name content, xmlattributes('html' as type), e.content)
		) order by e.updated desc, e.id) as entries,
		max(e.updated) as max_updated
		from entries e
	)
	select
		(e'<?xml version="1.0" encoding="UTF-8"?>\n' ||
		xmlserialize(document xmlroot(xmlelement(
			name feed,
			xmlattributes('http://www.w3.org/2005/Atom' as xmlns, 'en' as "xml:lang"),
			xmlforest(
				'https://' || f.uri as id,
				f.title,
				f.description as subtitle,
				xx.max_updated as updated
			),
			xmlelement(
				name link,
				xmlattributes('self' as rel, 'application/atom+xml' as type, 'https://' || f.uri as href)
			),
			xmlelement(
				name link,
				xmlattributes('alternate' as rel, 'text/html' as type, 'https://' || f.link as href)
			),
			xmlelement(
				name author,
				xmlelement(name name, 'Derek Sivers'),
				xmlelement(name uri, 'https://sive.rs/')
			),
			xx.entries
		), version '1.0') as text indent))::xml
	from feeds f
	cross join xmlinfo xx
	where f.uri = $1;
$$ language sql;
