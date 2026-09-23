insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('GB', 'ENG', 'England');

insert into people (id, name, state, country) values (4, 'DD', null, 'SG');
insert into people (id, name, state, country) values (5, 'EE', 'Singapore', 'SG');
insert into people (id, name, state, country) values (6, 'FF', 'ENG', 'GB');
insert into people (id, name, state, country) values (7, 'GG', 'ENG', 'GB');
insert into people (id, name, state, country) values (8, 'HH', 'ENG', 'GB');

insert into now_pages (id, person_id, short, long) values (4, 4, 'dd.com/now', 'https://dd.com/now');
insert into now_pages (id, person_id, short, long) values (5, 5, 'ee.com/now', 'https://ee.com/now');
insert into now_pages (id, person_id, short, long) values (6, 6, 'ff.com/now', 'https://ff.com/now');
insert into now_pages (id, person_id, short, long) values (7, 7, 'gg.com/now', 'https://gg.com/now');
insert into now_pages (id, person_id, short, long) values (8, 8, 'hh.com/now', 'https://hh.com/now');

insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (4, 'four', 't', 'title4', 'liner4', 'why4', 'thought4', 'red4');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (5, 'five', 'f', 'title5', 'liner5', 'why5', 'thought5', 'red5');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (6, 'six6', 't', null, 'liner6', 'why6', 'thought6', 'red6');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (7, 'sevn', 't', 'title7', 'liner7', 'why7', 'thought7', 'red7');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (8, 'eigh', 'f', 'title8', 'liner8', 'why8', null, null);

insert into templates (code, template) values ('nnn-sitemap', '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url>
 <loc>https://nownownow.com/</loc>
 <lastmod>{{ymd}}</lastmod>
 <changefreq>daily</changefreq>
</url>
<url>
 <loc>https://nownownow.com/nownownow.txt</loc>
 <lastmod>{{ymd}}</lastmod>
 <changefreq>daily</changefreq>
 <priority>0.1</priority>
</url>
<url>
 <loc>https://nownownow.com/about</loc>
 <priority>1.0</priority>
 <changefreq>yearly</changefreq>
</url>
{{#profiles}}
<url><loc>https://nownownow.com/{{uri}}</loc><priority>1.0</priority></url>
{{/profiles}}
{{#places}}
<url><loc>https://nownownow.com/{{url}}</loc><changefreq>monthly</changefreq></url>
{{/places}}
</urlset>
');

select plan(1);

select is(body, '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url>
 <loc>https://nownownow.com/</loc>
 <lastmod>2026-09-23</lastmod>
 <changefreq>daily</changefreq>
</url>
<url>
 <loc>https://nownownow.com/nownownow.txt</loc>
 <lastmod>2026-09-23</lastmod>
 <changefreq>daily</changefreq>
 <priority>0.1</priority>
</url>
<url>
 <loc>https://nownownow.com/about</loc>
 <priority>1.0</priority>
 <changefreq>yearly</changefreq>
</url>
<url><loc>https://nownownow.com/four</loc><priority>1.0</priority></url>
<url><loc>https://nownownow.com/sevn</loc><priority>1.0</priority></url>
<url><loc>https://nownownow.com/six6</loc><priority>1.0</priority></url>
<url><loc>https://nownownow.com/GB-ENG</loc><changefreq>monthly</changefreq></url>
<url><loc>https://nownownow.com/SG</loc><changefreq>monthly</changefreq></url>
</urlset>
')
from nnn.sitemap();

