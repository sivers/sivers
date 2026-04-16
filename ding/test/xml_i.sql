insert into templates values ('rss2-podcast', '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/i-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
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

insert into feeds (uri, link, title, description, imageurl) values ('sive.rs/i.rss', 'sive.rs/i', 'Derek Sivers interviews', 'as a guest on other podcasts', 'sive.rs/images/i.png');

insert into interviews (id, uri, ymdhm, name, host, summary) values (1, '2026-01-buddy', '2026-01-11T11:00:00', 'Buddy Holly', 'Buddy Holly', 'talkin music and Texas');
insert into interviews (id, uri, ymdhm, name, host, summary) values (2, '2026-02-dog', '2026-02-22T10:00:00', 'Dog’s World', 'Hound Dog', 'bones and drool');

insert into interviews (id, uri, ymdhm, name, host, summary) values (3, null, '2026-03-11T10:00:00', 'Future Show', 'Future Host', null);

insert into audios (id, filename, seconds, bytes) values (1, '2026-01-buddy.mp3', 123, 123456);
insert into audios (id, filename, seconds, bytes) values (2, '2026-02-dog.mp3', 234, 234567);

insert into media (audio, interview) values (1, 1);
insert into media (audio, interview) values (2, 2);


select plan(1);

select is(xml, '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/i-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<atom:link href="https://sive.rs/i.rss" rel="self" type="application/rss+xml" />
<language>en</language>
<link>https://sive.rs/i</link>
<title>Derek Sivers interviews</title>
<description>as a guest on other podcasts</description>
<pubDate>Sun, 22 Feb 2026 10:00:00 GMT</pubDate>
<lastBuildDate>Sun, 22 Feb 2026 10:00:00 GMT</lastBuildDate>
<ttl>1440</ttl>
<managingEditor>derek@sivers.org (Derek Sivers)</managingEditor>
<copyright>© 2026 Sivers Inc</copyright>
<itunes:explicit>false</itunes:explicit>
<itunes:owner>
	<itunes:name>Derek Sivers</itunes:name>
	<itunes:email>derek@sivers.org</itunes:email>
</itunes:owner>
<itunes:author>Derek Sivers</itunes:author>
<itunes:summary>as a guest on other podcasts</itunes:summary>
<itunes:category text="Society &amp; Culture"><itunes:category text="Philosophy"/></itunes:category>
<itunes:keywords>Derek Sivers,sivers,sive.rs</itunes:keywords>
<itunes:type>episodic</itunes:type>
<itunes:image href="https://sive.rs/images/i.png"/>
<image>
	<url>https://sive.rs/images/i.png</url>
	<link>https://sive.rs/i</link>
	<title>Derek Sivers interviews</title>
</image>
<item>
	<pubDate>Sun, 22 Feb 2026 10:00:00 GMT</pubDate>
	<guid>https://sive.rs/2026-02-dog</guid>
	<link>https://sive.rs/2026-02-dog</link>
	<title>Dog’s World by Hound Dog</title>
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>bones and drool</itunes:summary>
	<description><![CDATA[<p>bones and drool</p>]]></description>
	<content:encoded><![CDATA[<p>bones and drool</p>]]></content:encoded>
	<itunes:duration>234</itunes:duration>
	<enclosure url="https://m.sive.rs/2026-02-dog.mp3" type="audio/mpeg" length="234567"/>
</item>
<item>
	<pubDate>Sun, 11 Jan 2026 11:00:00 GMT</pubDate>
	<guid>https://sive.rs/2026-01-buddy</guid>
	<link>https://sive.rs/2026-01-buddy</link>
	<title>Buddy Holly</title>
	<itunes:episodeType>full</itunes:episodeType>
	<itunes:summary>talkin music and Texas</itunes:summary>
	<description><![CDATA[<p>talkin music and Texas</p>]]></description>
	<content:encoded><![CDATA[<p>talkin music and Texas</p>]]></content:encoded>
	<itunes:duration>123</itunes:duration>
	<enclosure url="https://m.sive.rs/2026-01-buddy.mp3" type="audio/mpeg" length="123456"/>
</item>
</channel>
</rss>')
from ding.xml_i();

