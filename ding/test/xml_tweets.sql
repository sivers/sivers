
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

insert into feeds (uri, link, title, description) values ('sive.rs/d.xml', 'sive.rs/d', 'Derek Sivers tweets', 'micro-posts, etc');

insert into tweets (id, time, message) values (123, '2026-01-23 12:07:59+13', 'testing one');
insert into tweets (id, time, message) values (124, '2026-01-24 12:34:56+13', 'this https://example.com/ is good');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/d.xml</id> 
<title>Derek Sivers tweets</title> 
<subtitle>micro-posts, etc</subtitle> 
<updated>2026-01-23T23:34:56Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/d.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/d"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
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
	<id>https://sive.rs/d/123</id>
	<title>testing one</title> 
	<published>2026-01-22T23:07:59Z</published>
	<updated>2026-01-22T23:07:59Z</updated>
	<link rel="alternate" type="text/html" href="https://sive.rs/d/123"/> 
	<summary type="text">testing one</summary> 
	<content type="html">&lt;p&gt;testing one&lt;/p&gt;</content>
</entry> 
</feed>')
from ding.xml_tweets();

