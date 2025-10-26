insert into articles (id, title, original) values (1, 'Article Title', e'<p>\n\tArticle content\n</p>');

insert into feeds (uri, link, title, description, imageurl, category, updated_at) values
('sive.rs/feed.rss', 'sive.rs/', 'Feed Title', 'feed description', 'sive.rs/blog.png', 'Category', '2025-10-22 12:34:57+00');

insert into feeds (uri, podcast, link, title, description, imageurl, category, keywords, updated_at) values
('sive.rs/podcast.rss', 'true', 'sive.rs/podcast', 'Podcast Title', 'podcast description', 'sive.rs/podcast.png', 'Category Ignored', 'some, keywords, here', '2025-10-22 12:34:59+00');

insert into feeditems (feed_uri, uri, title, content, pubdate) values
('sive.rs/feed.rss', 'sive.rs/one', 'First Title', e'<p><strong>First</strong> content</p>', '2025-10-22 12:34:56+00');

insert into feeditems (feed_uri, uri, article, pubdate) values
('sive.rs/feed.rss', 'sive.rs/two', 1, '2025-10-22 12:34:57+00');

insert into feeditems (feed_uri, uri, title, content, pubdate) values
('sive.rs/feed.rss', 'sive.rs/future', 'Future post', e'<p>Future post is not in this feed.</p>', '2075-12-31 00:00:00+00');

insert into feeditems (feed_uri, uri, pubdate, mediaurl, bytes, seconds, title, content) values
('sive.rs/podcast.rss', 'sive.rs/pod/1', '2025-10-22 12:34:59+00', 'sive.rs/one.mp3', 1234567, 123, 'One podcast episode', '<p>One podcast episode here with <strong>HTML markup</strong></p>');

insert into templates values ('feed', '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="{{uri}}" rel="self" type="application/rss+xml" />
<dc:creator>{{creator}}</dc:creator>
<language>en</language>
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

insert into templates values ('feed-podcast', '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="{{uri}}" rel="self" type="application/rss+xml" />
<language>en</language>
<link>{{link}}</link>
<title>{{title}}</title>
<description>{{description}}</description>
<pubDate>{{pubdate}}</pubDate>
<lastBuildDate>{{pubdate}}</lastBuildDate>
<ttl>{{ttl}}</ttl>
<managingEditor>derek@sivers.org (Derek Sivers)</managingEditor>
<copyright>© 2025 Sivers Inc</copyright>
<itunes:owner>
	<itunes:name>Derek Sivers</itunes:name>
	<itunes:email>derek@sivers.org</itunes:email>
</itunes:owner>
<itunes:author>Derek Sivers</itunes:author>
<itunes:summary>{{description}}</itunes:summary>
<itunes:category text="Society &amp; Culture"><itunes:category text="Philosophy"/></itunes:category>
<itunes:keywords>{{keywords}}</itunes:keywords>
<itunes:type>episodic</itunes:type>
<itunes:image href="{{imageurl}}"/>
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
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>{{description}}</itunes:summary>
	<content:encoded><![CDATA[{{{content}}}]]></content:encoded>
	<description><![CDATA[{{{content}}}]]></description>
	<itunes:duration>{{seconds}}</itunes:duration>
	<enclosure url="{{mediaurl}}" type="audio/mpeg" length="{{bytes}}"/>
</item>
{{/items}}
</channel>
</rss>');

select plan(2);

select is(xml, '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="https://sive.rs/feed.rss" rel="self" type="application/rss+xml" />
<dc:creator>Derek Sivers</dc:creator>
<language>en</language>
<category>Category</category>
<link>https://sive.rs/</link>
<title>Feed Title</title>
<description>feed description</description>
<pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate>
<lastBuildDate>Wed, 22 Oct 2025 12:34:57 GMT</lastBuildDate>
<ttl>1440</ttl>
<image>
	<url>https://sive.rs/blog.png</url>
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


select is(xml, '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="https://sive.rs/podcast.rss" rel="self" type="application/rss+xml" />
<language>en</language>
<link>https://sive.rs/podcast</link>
<title>Podcast Title</title>
<description>podcast description</description>
<pubDate>Wed, 22 Oct 2025 12:34:59 GMT</pubDate>
<lastBuildDate>Wed, 22 Oct 2025 12:34:59 GMT</lastBuildDate>
<ttl>1440</ttl>
<managingEditor>derek@sivers.org (Derek Sivers)</managingEditor>
<copyright>© 2025 Sivers Inc</copyright>
<itunes:owner>
	<itunes:name>Derek Sivers</itunes:name>
	<itunes:email>derek@sivers.org</itunes:email>
</itunes:owner>
<itunes:author>Derek Sivers</itunes:author>
<itunes:summary>podcast description</itunes:summary>
<itunes:category text="Society &amp; Culture"><itunes:category text="Philosophy"/></itunes:category>
<itunes:keywords>some, keywords, here</itunes:keywords>
<itunes:type>episodic</itunes:type>
<itunes:image href="https://sive.rs/podcast.png"/>
<image>
	<url>https://sive.rs/podcast.png</url>
	<link>https://sive.rs/podcast</link>
	<title>Podcast Title</title>
</image>
<item>
	<pubDate>Wed, 22 Oct 2025 12:34:59 GMT</pubDate>
	<guid>https://sive.rs/pod/1</guid>
	<link>https://sive.rs/pod/1</link>
	<title>One podcast episode</title>
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>One podcast episode here with HTML markup</itunes:summary>
	<content:encoded><![CDATA[<p>One podcast episode here with <strong>HTML markup</strong></p>]]></content:encoded>
	<description><![CDATA[<p>One podcast episode here with <strong>HTML markup</strong></p>]]></description>
	<itunes:duration>123</itunes:duration>
	<enclosure url="https://sive.rs/one.mp3" type="audio/mpeg" length="1234567"/>
</item>
</channel>
</rss>')
from o.feed('sive.rs/podcast.rss');

