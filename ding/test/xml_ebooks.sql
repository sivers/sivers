
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

insert into ebooknotes (ebook_code, sortid, note) values ('BookOne', 1, 'Notes paragraph one.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookOne', 2, 'Notes paragraph two.');

insert into ebooknotes (ebook_code, sortid, note) values ('BookTwo', 1, e'Think.\nAct.\nLie.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookTwo', 2, 'Just two.');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/book.xml</id> 
<title>Derek Sivers book notes</title> 
<subtitle>my notes on books I’ve read</subtitle> 
<updated>2026-02-02T00:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/book.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/book"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
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
	<id>https://sive.rs/book/BookOne</id>
	<title>Book One - by Author One</title> 
	<published>2026-01-01T00:00:00Z</published>
	<updated>2026-01-01T00:00:00Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/book/BookOne"/> 
	<summary type="text">Boy this was a good book.</summary> 
	<content type="html">&lt;h2&gt;summary:&lt;/h2&gt;&lt;p&gt;Boy this was a good book.&lt;/p&gt;&lt;h2&gt;recommend: 8/10&lt;/h2&gt;&lt;img src=&quot;https://sive.rs/images/book/BookOne.webp&quot;&gt;&lt;h2&gt;my notes:&lt;/h2&gt;&lt;p&gt;Notes paragraph one.&lt;/p&gt;&lt;p&gt;Notes paragraph two.&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_ebooks();


