insert into templates values ('rss2-podcast', '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="{{uri}}" rel="self" type="application/rss+xml" />
<language>en</language>
<link>{{link}}</link>
<title>{{title}}</title>
<description>{{description}}</description>
<pubDate>{{pubdate}}</pubDate>
<lastBuildDate>{{pubdate}}</lastBuildDate>
<ttl>1440</ttl>
<managingEditor>derek@sivers.org (Derek Sivers)</managingEditor>
<copyright>© 2026 Sivers Inc</copyright>
<itunes:explicit>false</itunes:explicit>
<itunes:owner>
	<itunes:name>Derek Sivers</itunes:name>
	<itunes:email>derek@sivers.org</itunes:email>
</itunes:owner>
<itunes:author>Derek Sivers</itunes:author>
<itunes:summary>{{description}}</itunes:summary>
<itunes:category text="Society &amp; Culture"><itunes:category text="Philosophy"/></itunes:category>
<itunes:keywords>Derek Sivers,sivers,sive.rs</itunes:keywords>
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
	<description><![CDATA[{{{content}}}]]></description>
	<content:encoded><![CDATA[{{{content}}}]]></content:encoded>
	<itunes:duration>{{seconds}}</itunes:duration>
	<enclosure url="{{mediaurl}}" type="audio/mpeg" length="{{bytes}}"/>
</item>
{{/items}}
</channel>
</rss>');

insert into feeds (uri, link, title, description, imageurl) values ('sive.rs/podcast.rss', 'sive.rs/podcast', 'Derek Sivers podcast', 'all my best', 'sive.rs/images/podcast.png');

insert into articles (id, uri, posted, title, original) values (1, 'one', '2026-01-23', 'Article One', e'<p>\n\tWhy stay?\n\tLet’s go <a href="/">home</a>!\t\n</p>');
insert into articles (id, uri, posted, title, original) values (2, 'two', '2026-01-24', 'Two for the Lonely', e'<p>\n\tNo links here.\n</p>');

insert into articles (id, uri, posted, title, original) values (3, 'no', '2026-01-25', 'NO AUDIO', e'<p>DO NOT POST</p>');

insert into audios (id, filename, seconds, bytes) values (1, 'sive.rs.one.mp3', 123, 123456);
insert into audios (id, filename, seconds, bytes) values (2, 'sive.rs.two.mp3', 234, 234567);

insert into media (audio, article) values (1, 1);
insert into media (audio, article) values (2, 2);


select plan(1);

select is(xml, '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="https://sive.rs/podcast.rss" rel="self" type="application/rss+xml" />
<language>en</language>
<link>https://sive.rs/podcast</link>
<title>Derek Sivers podcast</title>
<description>all my best</description>
<pubDate>Fri, 23 Jan 2026 11:00:00 GMT</pubDate>
<lastBuildDate>Fri, 23 Jan 2026 11:00:00 GMT</lastBuildDate>
<ttl>1440</ttl>
<managingEditor>derek@sivers.org (Derek Sivers)</managingEditor>
<copyright>© 2026 Sivers Inc</copyright>
<itunes:explicit>false</itunes:explicit>
<itunes:owner>
	<itunes:name>Derek Sivers</itunes:name>
	<itunes:email>derek@sivers.org</itunes:email>
</itunes:owner>
<itunes:author>Derek Sivers</itunes:author>
<itunes:summary>all my best</itunes:summary>
<itunes:category text="Society &amp; Culture"><itunes:category text="Philosophy"/></itunes:category>
<itunes:keywords>Derek Sivers,sivers,sive.rs</itunes:keywords>
<itunes:type>episodic</itunes:type>
<itunes:image href="https://sive.rs/images/podcast.png"/>
<image>
	<url>https://sive.rs/images/podcast.png</url>
	<link>https://sive.rs/podcast</link>
	<title>Derek Sivers podcast</title>
</image>
<item>
	<pubDate>Fri, 23 Jan 2026 11:00:00 GMT</pubDate>
	<guid>https://sive.rs/two</guid>
	<link>https://sive.rs/two</link>
	<title>Two for the Lonely</title>
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>No links here.</itunes:summary>
	<description><![CDATA[<p>
	No links here.
</p>]]></description>
	<content:encoded><![CDATA[<p>
	No links here.
</p>]]></content:encoded>
	<itunes:duration>234</itunes:duration>
	<enclosure url="https://m.sive.rs/sive.rs.two.mp3" type="audio/mpeg" length="234567"/>
</item>
<item>
	<pubDate>Thu, 22 Jan 2026 11:00:00 GMT</pubDate>
	<guid>https://sive.rs/one</guid>
	<link>https://sive.rs/one</link>
	<title>Article One</title>
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>Why stay? Let’s go home!</itunes:summary>
	<description><![CDATA[<p>
	Why stay?
	Let’s go <a href="https://sive.rs/">home</a>!	
</p>]]></description>
	<content:encoded><![CDATA[<p>
	Why stay?
	Let’s go <a href="https://sive.rs/">home</a>!	
</p>]]></content:encoded>
	<itunes:duration>123</itunes:duration>
	<enclosure url="https://m.sive.rs/sive.rs.one.mp3" type="audio/mpeg" length="123456"/>
</item>
</channel>
</rss>')
from ding.xml_podcast();

