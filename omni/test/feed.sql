insert into feeds (uri, link, title, description) values ('sive.rs/feed.rss', 'sive.rs/', 'a feed', 'a description');
insert into feeditems (feed_uri, uri, title, pubdate) values ('sive.rs/feed.rss', 'sive.rs/one', 'one', '2025-10-22 12:34:56+00');
insert into feeditems (feed_uri, uri, title, pubdate) values ('sive.rs/feed.rss', 'sive.rs/two', 'two', '2025-10-22 12:34:57+00');

select plan(1);

select is(xml, '<?xml version="1.0"?>
<rss version="2.0">
<channel>
<title>a feed</title>
<link>https://sive.rs/</link>
<description>a description</description>
<item><title>two</title><pubDate>Wed, 22 Oct 2025 12:34:57 GMT</pubDate></item>
<item><title>one</title><pubDate>Wed, 22 Oct 2025 12:34:56 GMT</pubDate></item>
</channel>
</rss>')
from o.feed('sive.rs/feed.rss');

