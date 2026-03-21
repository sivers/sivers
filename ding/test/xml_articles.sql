
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

insert into feeds (uri, link, title, description) values ('sive.rs/articles.xml', 'sive.rs/articles', 'Derek Sivers articles', 'all my best');

insert into articles (id, uri, posted, title, original) values (1, 'one', '2026-01-23', 'Article One', e'<p>\n\tWhy stay?\n\tLet’s go <a href="/">home</a>!\t\n</p>');
insert into articles (id, uri, posted, title, original) values (2, 'two', '2026-01-24', 'Two for the Lonely', e'<p>\n\tNo links here.\n</p>');

select plan(1);

select is(xml, '<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"> 
<id>https://sive.rs/articles.xml</id> 
<title>Derek Sivers articles</title> 
<subtitle>all my best</subtitle> 
<updated>2026-01-24T00:00:00Z</updated>
<link rel="self" type="application/atom+xml" href="https://sive.rs/articles.xml"/>
<link rel="alternate" type="text/html" href="https://sive.rs/articles"/> 
<author><name>Derek Sivers</name><uri>https://sive.rs/</uri></author>
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
</feed>')
from ding.xml_articles();

