
insert into templates values ('atom', '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>{{id}}</id> 
<title>{{title}}</title> 
<subtitle>{{subtitle}}</subtitle> 
<updated>{{updated}}</updated>
<link rel="self" type="application/atom+xml" href="{{id}}"/>
<link rel="alternate" type="text/html" href="{{link}}"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
{{#items}}
<entry>
	<id>{{id}}</id>
	<title>{{title}}</title> 
	<published>{{published}}</published>
	<updated>{{updated}}</updated>
	<link rel="alternate" type="text/html" href="{{link}}"/> 
	<summary type="text">{{summary}}</summary> 
	<content type="html">{{content}}</content>
</entry> 
{{/items}}
</feed>');

insert into feeds (uri, link, title, description) values ('nownownow.com/feed.xml', 'nownownow.com/', 'New /now pages', 'from nownownow.com');

insert into countries (code, name) values ('AE', 'United Arab Emirates');
insert into countries (code, name) values ('IT', 'Italy');

insert into people (id, name, city, country) values (1, 'Persono Uno', 'Dubai', 'AE');
insert into people (id, name, city, country) values (2, 'Bella Dua', 'Roma', 'IT');

insert into now_pages (id, person_id, created_at, updated_at, short, long) values (333, 1, '2026-01-01', '2026-01-01', 'example1.com/now', 'https://www.example1.com/now');
insert into now_pages (id, person_id, created_at, updated_at, short, long) values (334, 2, '2026-02-02', '2026-02-02', 'example2.com/now', 'https://www.example2.com/now');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://nownownow.com/feed.xml</id> 
<title>New /now pages</title> 
<subtitle>from nownownow.com</subtitle> 
<updated>2026-02-01T11:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://nownownow.com/feed.xml"/>
<link rel="alternate" type="text/html" href="https://nownownow.com/"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
<entry>
	<id>https://www.example2.com/now</id>
	<title>Bella Dua in Roma, Italy</title> 
	<published>2026-02-01T11:00:00Z</published>
	<updated>2026-02-01T11:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://www.example2.com/now"/> 
	<summary type="text">example2.com/now</summary> 
	<content type="html">&lt;p&gt;&lt;a href=&quot;https://www.example2.com/now&quot;&gt;example2.com/now&lt;/a&gt;&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://www.example1.com/now</id>
	<title>Persono Uno in Dubai, United Arab Emirates</title> 
	<published>2025-12-31T11:00:00Z</published>
	<updated>2025-12-31T11:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://www.example1.com/now"/> 
	<summary type="text">example1.com/now</summary> 
	<content type="html">&lt;p&gt;&lt;a href=&quot;https://www.example1.com/now&quot;&gt;example1.com/now&lt;/a&gt;&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_nownownow();

