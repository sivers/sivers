
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

insert into feeds (uri, link, title, description) values ('sive.rs/i.xml', 'sive.rs/i', 'Derek Sivers interviews', 'talk talk talk');

insert into interviews (uri, ymdhm, name, host, summary) values ('2026-01-buddy', '2026-01-11T11:00:00', 'Buddy Holly', 'Buddy Holly', 'talkin music and Texas');
insert into interviews (uri, ymdhm, name, host, summary) values ('2026-02-dog', '2026-02-22T10:00:00', 'Dog’s World', 'Hound Dog', 'bones and drool');

insert into interviews (ymdhm, name, host) values ('2029-12-22T10:00:00', 'Future One', 'Future Host');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/i.xml</id> 
<title>Derek Sivers interviews</title> 
<subtitle>talk talk talk</subtitle> 
<updated>2026-02-21T21:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/i.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/i"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
<entry>
	<id>https://sive.rs/2026-02-dog</id>
	<title>Dog’s World by Hound Dog</title> 
	<published>2026-02-21T21:00:00Z</published>
	<updated>2026-02-21T21:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/2026-02-dog"/> 
	<summary type="text">bones and drool</summary> 
	<content type="html">&lt;p&gt;bones and drool&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/2026-01-buddy</id>
	<title>Buddy Holly</title> 
	<published>2026-01-10T22:00:00Z</published>
	<updated>2026-01-10T22:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/2026-01-buddy"/> 
	<summary type="text">talkin music and Texas</summary> 
	<content type="html">&lt;p&gt;talkin music and Texas&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_interviews();

