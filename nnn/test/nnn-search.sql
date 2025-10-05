insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('GB', 'ENG', 'England');

insert into people (id, name, city, state, country) values (4, 'David Gao Lin', 'Singapore', null, 'SG');
insert into people (id, name, city, state, country) values (7, 'Linda Gaosho', 'Oxford', 'ENG', 'GB');

insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (4, 'four', 't', 'boxing title', 'butter liner', 'why anything', 'deep thought', 'awful book');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (7, 'sevn', 'f', 'tiny title', 'ocean liner', 'why not', 'thoughtful', 'great book');

insert into templates (code, template) values ('nnn-wrap', e'<html><title>{{pagetitle}}</title>\n{{{core}}}\n</html>');
insert into templates (code, template) values ('nnn-search', '<form action="/search" method="get">
<fieldset role="group">
<input type="search" name="q" required>
<input type="submit" value="search">
</fieldset>
</form>

<h1>searching for “{{q}}”</h1>

{{#none}}
<p>Sorry. Nothing found.</p>
{{/none}}

{{^none}}

{{#name}}
<h2>names with “{{q}}”</h2>
<ul>
{{#name}}
<li>{{#photo}}{{public_id}}{{/photo}} {{name}} {{title}}</li>
{{/name}}
</ul>
{{/name}}

{{#city}}
<h2>cities with “{{q}}”</h2>
<ul>
{{#city}}
<li>{{#photo}}{{public_id}}{{/photo}} {{name}} {{title}}</li>
{{/city}}
</ul>
{{/city}}

{{#answers}}
<h2>profiles with “{{q}}”</h2>
<ul>
{{#answers}}
<li>{{#photo}}{{public_id}}{{/photo}} {{name}} {{title}}</li>
{{/answers}}
</ul>
{{/answers}}

{{/none}}');


select plan(26);

select is(head, e'303\r\nLocation: /'),
        is(body, null, 'no null')
from nnn.search(null);

select is(head, e'303\r\nLocation: /'),
        is(body, null, 'minimum 3 chars after trim')
from nnn.search('  GB  ');

select is(head, e'303\r\nLocation: /SG'),
        is(body, null, 'country')
from nnn.search('   SINGAPORE ');

select is(head, e'303\r\nLocation: /GB-ENG'),
        is(body, null, 'state')
from nnn.search(' england ');

select is(head, e'303\r\nLocation: /GB-ENG'),
        is(body, null, 'cleaned')
from nnn.search(' “england”! ');

select is(head, null, 'no /GB') from nnn.search('United Kingdom');

select ok(strpos(body, '<h1>searching for “xxxxx”') > 0, 'shown in title'),
	ok(strpos(body, '<p>Sorry. Nothing found.</p>') > 0, 'says not found')
from nnn.search('xxxxx');

select ok(strpos(body, '<h2>names with “lin”</h2>') > 0, 'yes names'),
	ok(strpos(body, '<h2>cities with “lin”</h2>') = 0, 'no cities'),
	ok(strpos(body, '<h2>profiles with “lin”</h2>') > 0, 'yes profiles'),
	ok(strpos(body, e'<ul>\n<li>four David Gao Lin boxing title</li>\n<li> Linda Gaosho tiny title</li>\n</ul>') > 0, 'both')
	-- actually appears twice but I'm too lazy to figure out how to test for that
from nnn.search(' LIN ');

select ok(strpos(body, '<h1>searching for “oxford”') > 0, 'clean in title'),
	ok(strpos(body, '<h2>names with “oxford”</h2>') = 0, 'no names'),
	ok(strpos(body, '<h2>cities with “oxford”</h2>') > 0, 'cities header'),
	ok(strpos(body, '<h2>profiles with “oxford”</h2>') = 0, 'no profiles'),
	ok(strpos(body, e'<ul>\n<li> Linda Gaosho tiny title</li>\n</ul>') > 0, 'no photo')
from nnn.search(' OXFORD! ');

select ok(strpos(body, '<h2>names with “liner”</h2>') = 0, 'no names'),
	ok(strpos(body, '<h2>cities with “liner”</h2>') = 0, 'no cities'),
	ok(strpos(body, '<h2>profiles with “liner”</h2>') > 0, 'clean in profiles'),
	ok(strpos(body, e'<ul>\n<li>four David Gao Lin boxing title</li>\n<li> Linda Gaosho tiny title</li>\n</ul>') > 0, 'both')
from nnn.search('<liner;>');


