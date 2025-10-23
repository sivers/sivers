insert into feeds (uri, link, title, description, category, updated_at) values
('sive.rs/feed.rss', 'sive.rs/', 'a feed', 'a description', 'a category', '2025-10-22 12:34:57+00');
insert into feeditems (feed_uri, uri, title, content, pubdate) values ('sive.rs/feed.rss', 'sive.rs/one', 'one', 'One content, one!', '2025-10-22 12:34:56+00');
insert into feeditems (feed_uri, uri, title, content, pubdate) values ('sive.rs/feed.rss', 'sive.rs/two', 'two', 'Two content, two!', '2025-10-22 12:34:57+00');

select plan(1);

select is(xml, '<?xml version="1.0"?>
<rss version="2.0">
<channel>
<title>a feed</title>
<link>https://sive.rs/</link>
<description>a description</description>
<language>en-us</language>
<lastBuildDate>Wed, 22 Oct 2025 12:34:57 GMT</lastBuildDate>
<pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate>
<ttl>1440</ttl>
<item>
<title>two</title>
<guid isPermaLink="true">https://sive.rs/two</guid>
<link>https://sive.rs/two</link>
<author>Derek Sivers</author>
<category>a category</category>
<pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate>
</item>
<item>
<title>one</title>
<guid isPermaLink="true">https://sive.rs/one</guid>
<link>https://sive.rs/one</link>
<author>Derek Sivers</author>
<category>a category</category>
<pubDate>Wed, 22 Oct 2025 12:34:56 GMT</pubDate>
</item>
</channel>
</rss>')
from o.feed('sive.rs/feed.rss');

