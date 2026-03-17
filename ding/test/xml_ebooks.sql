
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

insert into feeds (uri, link, title, description) values ('sive.rs/book.xml', 'sive.rs/book', 'Derek Sivers book notes', 'my notes on books I’ve read');

insert into ebooks (code, title, author, read, rating, summary) values ('no', 'Not Listed', 'not until summary', '2026-03-13', null, null);
insert into ebooks (code, title, author, read, rating, summary) values ('BookOne', 'Book One', 'Author One', '2026-01-01', 8, 'Boy this was a good book.');
insert into ebooks (code, title, author, read, rating, summary) values ('BookTwo', 'Book Two', 'Author Two', '2026-02-02', 5, 'This was just OK.');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/book.xml</id> 
<title>Derek Sivers book notes</title> 
<subtitle>my notes on books I’ve read</subtitle> 
<updated>2026-02-01T11:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/book.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/book"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
<entry>
	<id>https://sive.rs/book/BookTwo</id>
	<title>Book Two - by Author Two</title> 
	<published>2026-02-01T11:00:00Z</published>
	<updated>2026-02-01T11:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/book/BookTwo"/> 
	<summary type="text">This was just OK.</summary> 
	<content type="html">&lt;p&gt;This was just OK.&lt;/p&gt;</content>
</entry> 
<entry>
	<id>https://sive.rs/book/BookOne</id>
	<title>Book One - by Author One</title> 
	<published>2025-12-31T11:00:00Z</published>
	<updated>2025-12-31T11:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/book/BookOne"/> 
	<summary type="text">Boy this was a good book.</summary> 
	<content type="html">&lt;p&gt;Boy this was a good book.&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_ebooks();

