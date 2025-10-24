insert into articles (id, title, original) values (1, 'Article Title', e'<p>\n\tArticle content\n</p>');

insert into feeds (uri, link, title, description, imageurl, category, updated_at) values
('sive.rs/feed.rss', 'sive.rs/', 'Feed Title', 'feed description', 'sive.rs/podcast.png', 'Category', '2025-10-22 12:34:57+00');

insert into feeditems (feed_uri, uri, title, content, pubdate) values ('sive.rs/feed.rss', 'sive.rs/one', 'First Title', e'<p><strong>First</strong> content</p>', '2025-10-22 12:34:56+00');
insert into feeditems (feed_uri, uri, article_id, pubdate) values ('sive.rs/feed.rss', 'sive.rs/two', 1, '2025-10-22 12:34:57+00');

insert into templates values ('feed', '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="{{uri}}" rel="self" type="application/rss+xml" />
<dc:creator>{{creator}}</dc:creator>
<language>{{language}}</language>
<category>{{category}}</category>
<link>{{link}}</link>
<title>{{title}}</title>
<description>{{description}}</description>
<pubDate>{{pubdate}}</pubDate>
<lastBuildDate>{{pubdate}}</lastBuildDate>
<ttl>{{ttl}}</ttl>
<image>
	<url>{{imageurl}}</url>
	<link>{{link}}</link>
	<title>{{title}}</title>
</image>
{{#items}}
<item>
	<pubDate>{{pubdate}}</pubDate>
	<guid>{{link}}</guid>
	<link>{{link}}</link>
	<title>{{title}}</title>
	<description>{{description}}</description>
	<content:encoded><![CDATA[{{{content}}}]]></content:encoded>
</item>
{{/items}}
</channel>
</rss>');

select plan(1);

select is(xml, '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="https://sive.rs/feed.rss" rel="self" type="application/rss+xml" />
<dc:creator>Derek Sivers</dc:creator>
<language>en-us</language>
<category>Category</category>
<link>https://sive.rs/</link>
<title>Feed Title</title>
<description>feed description</description>
<pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate>
<lastBuildDate>Wed, 22 Oct 2025 12:34:57 GMT</lastBuildDate>
<ttl>1440</ttl>
<image>
	<url>https://sive.rs/podcast.png</url>
	<link>https://sive.rs/</link>
	<title>Feed Title</title>
</image>
<item>
	<pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate>
	<guid>https://sive.rs/two</guid>
	<link>https://sive.rs/two</link>
	<title>Article Title</title>
	<description>Article content</description>
	<content:encoded><![CDATA[<p>
	Article content
</p>]]></content:encoded>
</item>
<item>
	<pubDate>Wed, 22 Oct 2025 12:34:56 GMT</pubDate>
	<guid>https://sive.rs/one</guid>
	<link>https://sive.rs/one</link>
	<title>First Title</title>
	<description>First content</description>
	<content:encoded><![CDATA[<p><strong>First</strong> content</p>]]></content:encoded>
</item>
</channel>
</rss>')
from o.feed('sive.rs/feed.rss');

