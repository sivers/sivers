-- combine all feeds into one: sive.rs/feed.xml
-- tweets, articles, books, interviews

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

insert into feeds (uri, link, title, description) values ('sive.rs/feed.xml', 'sive.rs/', 'Derek Sivers', 'everything');

insert into tweets (id, time, message) values (123, '2026-01-23 12:07:59+13', 'testing one');
insert into tweets (id, time, message) values (124, '2026-01-24 12:34:56+13', 'this https://example.com/ is good');

insert into articles (id, uri, posted, title, original) values (1, 'one', '2026-01-23', 'Article One', e'<p>\n\tWhy stay?\n\tLet’s go <a href="/">home</a>!\t\n</p>');
insert into articles (id, uri, posted, title, original) values (2, 'two', '2026-01-24', 'Two for the Lonely', e'<p>\n\tNo links here.\n</p>');

insert into ebooks (code, title, author, read, rating, summary) values ('no', 'Not Listed', 'not until summary', '2026-03-13', null, null);
insert into ebooks (code, title, author, read, rating, summary) values ('BookOne', 'Book One', 'Author One', '2026-01-01', 8, 'Boy this was a good book.');
insert into ebooks (code, title, author, read, rating, summary) values ('BookTwo', 'Book Two', 'Author Two', '2026-02-02', 5, 'This was just OK.');

insert into ebooknotes (ebook_code, sortid, note) values ('BookOne', 1, 'Notes paragraph one.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookOne', 2, 'Notes paragraph two.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookTwo', 1, e'Think.\nAct.\nLie.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookTwo', 2, 'Just two.');

insert into interviews (uri, ymdhm, name, host, summary) values ('2026-01-buddy', '2026-01-11T11:00:00', 'Buddy Holly', 'Buddy Holly', 'talkin music and Texas');
insert into interviews (uri, ymdhm, name, host, summary) values ('2026-02-dog', '2026-02-22T10:00:00', 'Dog’s World', 'Hound Dog', 'bones and drool');

insert into interviews (ymdhm, name, host) values ('2029-12-22T10:00:00', 'Future One', 'Future Host');


select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/feed.xml</id> 
<title>Derek Sivers</title> 
<subtitle>everything</subtitle> 
<updated>2026-02-22T10:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/feed.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
<entry>
	<id>https://sive.rs/2026-02-dog</id>
	<title>Dog’s World by Hound Dog</title> 
	<published>2026-02-22T10:00:00Z</published>
	<updated>2026-02-22T10:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/2026-02-dog"/> 
	<summary type="text">bones and drool</summary> 
	<content type="html">&lt;p&gt;bones and drool&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/book/BookTwo</id>
	<title>Book Two - by Author Two</title> 
	<published>2026-02-02T00:00:00Z</published>
	<updated>2026-02-02T00:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/book/BookTwo"/> 
	<summary type="text">This was just OK.</summary> 
	<content type="html">&lt;h2&gt;summary:&lt;/h2&gt;&lt;p&gt;This was just OK.&lt;/p&gt;&lt;h2&gt;recommend: 5/10&lt;/h2&gt;&lt;img src=&quot;https://sive.rs/images/book/BookTwo.webp&quot;&gt;&lt;h2&gt;my notes:&lt;/h2&gt;&lt;p&gt;Think.
Act.
Lie.&lt;/p&gt;&lt;p&gt;Just two.&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/two</id>
	<title>Two for the Lonely</title> 
	<published>2026-01-24T00:00:00Z</published>
	<updated>2026-01-24T00:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/two"/> 
	<summary type="text">No links here.</summary> 
	<content type="html">&lt;p&gt;
	No links here.
&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/d/124</id>
	<title>this https://example.com/ is good</title> 
	<published>2026-01-23T23:34:56Z</published>
	<updated>2026-01-23T23:34:56Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/d/124"/> 
	<summary type="text">this https://example.com/ is good</summary> 
	<content type="html">&lt;p&gt;this &lt;a href=&quot;https://example.com/&quot;&gt;example.com/&lt;/a&gt; is good&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/one</id>
	<title>Article One</title> 
	<published>2026-01-23T00:00:00Z</published>
	<updated>2026-01-23T00:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/one"/> 
	<summary type="text">Why stay?</summary> 
	<content type="html">&lt;p&gt;
	Why stay?
	Let’s go &lt;a href=&quot;https://sive.rs/&quot;&gt;home&lt;/a&gt;!	
&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/d/123</id>
	<title>testing one</title> 
	<published>2026-01-22T23:07:59Z</published>
	<updated>2026-01-22T23:07:59Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/d/123"/> 
	<summary type="text">testing one</summary> 
	<content type="html">&lt;p&gt;testing one&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/2026-01-buddy</id>
	<title>Buddy Holly</title> 
	<published>2026-01-11T11:00:00Z</published>
	<updated>2026-01-11T11:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/2026-01-buddy"/> 
	<summary type="text">talkin music and Texas</summary> 
	<content type="html">&lt;p&gt;talkin music and Texas&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/book/BookOne</id>
	<title>Book One - by Author One</title> 
	<published>2026-01-01T00:00:00Z</published>
	<updated>2026-01-01T00:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/book/BookOne"/> 
	<summary type="text">Boy this was a good book.</summary> 
	<content type="html">&lt;h2&gt;summary:&lt;/h2&gt;&lt;p&gt;Boy this was a good book.&lt;/p&gt;&lt;h2&gt;recommend: 8/10&lt;/h2&gt;&lt;img src=&quot;https://sive.rs/images/book/BookOne.webp&quot;&gt;&lt;h2&gt;my notes:&lt;/h2&gt;&lt;p&gt;Notes paragraph one.&lt;/p&gt;&lt;p&gt;Notes paragraph two.&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_all();

