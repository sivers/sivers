insert into articles (uri, posted, title) values ('three', '2026-01-03', 'Title Three');
insert into articles (uri, posted, title) values ('four', '2026-01-04', 'Title Four');
insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '2026-02-08', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 8, '2026-02-09', '.');
insert into presentations (uri, title, description, month, minutes) values ('blah', 'Blah Blah', 'Blah blah blah, and blah.', '2023-03', 33);
insert into presentations (uri, title, description, month, minutes) values ('six', 'Sixty', 'Six oh six.', '2026-06', 6);
insert into interviews (uri, ymdhm, name, host, summary) values ('2026-01-02-one', '2026-01-02 12:00:00', 'One Show', 'One Host', 'One summary here.');
insert into interviews (uri, ymdhm, name, host, summary) values ('2026-02-03-two', '2026-02-03 12:00:00', 'Two Man', 'Two Man', 'Two man was good.');
insert into meetwheres (id, display) values (1, '2025-01 - One Place');
insert into meetwheres (id, display) values (2, '2026-02 - Two Place');
insert into meetwheres (id, display) values (3, '2099-12 - Future Place');
insert into people (id, name) values (1, 'Mrs. One');
insert into people (id, name) values (2, 'Mr. Two');
insert into people (id, name) values (3, 'Miss Three');
insert into people (id, name) values (4, 'Sir Four');
insert into people (id, name) values (5, 'Dr. Five');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (1, 1, 1, '2025-01-15 12:00:00+00', 'topics one', 'notes one');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (2, 1, 3, '2025-01-16 12:00:00+00', 'three topics', 'three notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (3, 2, 2, '2026-02-22 12:00:00+00', 'two topics', 'two notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (4, 2, 4, '2026-02-04 12:00:00+00', 'topics four', 'notes four');
insert into meetings (id, where_id, person_id, whatime, notes) values (5, 3, 5, '2099-12-12 12:00:00+00', 'FUTURE so unlisted');

select plan(1);
select is(body, '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url><loc>https://sive.rs/</loc><lastmod>' || current_date || '</lastmod></url>
<url><loc>https://sive.rs/a</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/about</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/ai</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/feeds</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/fp</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/h</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/hiring</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/m</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/music</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/n</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/now</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/privacy</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/sorry</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/thanks</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/ti</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/u</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/uses</loc><lastmod>2026-04-12</lastmod></url>
<url><loc>https://sive.rs/four</loc><lastmod>2026-01-04</lastmod></url>
<url><loc>https://sive.rs/three</loc><lastmod>2026-01-03</lastmod></url>
<url><loc>https://sive.rs/book/BookNine</loc><lastmod>2026-02-09</lastmod></url>
<url><loc>https://sive.rs/book/BookEight</loc><lastmod>2026-02-08</lastmod></url>
<url><loc>https://sive.rs/2026-02-03-two</loc><lastmod>2026-02-03</lastmod></url>
<url><loc>https://sive.rs/2026-01-02-one</loc><lastmod>2026-01-02</lastmod></url>
<url><loc>https://sive.rs/met/at-1</loc><lastmod>2025-01-16</lastmod></url>
<url><loc>https://sive.rs/met/at-2</loc><lastmod>2026-02-22</lastmod></url>
<url><loc>https://sive.rs/met/1</loc><lastmod>2025-01-15</lastmod></url>
<url><loc>https://sive.rs/met/2</loc><lastmod>2025-01-16</lastmod></url>
<url><loc>https://sive.rs/met/3</loc><lastmod>2026-02-22</lastmod></url>
<url><loc>https://sive.rs/met/4</loc><lastmod>2026-02-04</lastmod></url>
<url><loc>https://sive.rs/six</loc><lastmod>2026-06-15</lastmod></url>
<url><loc>https://sive.rs/blah</loc><lastmod>2023-03-15</lastmod></url>
</urlset>')
from me.sitemap();
-- TODO: change dates above to be newer than 2026-04-12 to test
