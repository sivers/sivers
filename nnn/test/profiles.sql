insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('GB', 'ENG', 'England');

insert into people (id, name, city, state, country) values (4, 'DD', 'Singapore', null, 'SG');
insert into people (id, name, city, state, country) values (7, 'GG', 'Oxford', 'ENG', 'GB');

insert into urls (person_id, url, main) values (4, 'https://x.com/dd', false);
insert into urls (person_id, url, main) values (4, 'https://bsky.app/dd', false);
insert into urls (person_id, url, main) values (4, 'https://dd1.com/', true);
insert into urls (person_id, url, main) values (7, 'https://facebook.com/gg', false);
insert into urls (person_id, url, main) values (7, 'https://gg.com/', true);

insert into now_pages (id, person_id, short, long) values (3, 4, 'dd1.com/now', 'https://dd1.com/now');
insert into now_pages (id, person_id, short, long) values (4, 4, 'dd2.com/now', 'https://dd2.com/now');
insert into now_pages (id, person_id, short, long) values (7, 7, 'gg.com/now', 'https://gg.com/now');

insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (4, 'four', 't', 'title4', 'liner4', 'why4', 'thought4', 'red4');
insert into now_profiles (id, public_id, photo, title, liner, why, thought, red) values (7, 'sevn', 't', 'title7', 'liner7', 'why7', 'thought7', 'red7');

insert into templates (code, template) values ('nnn-wrap', e'<html><title>{{pagetitle}}</title>\n{{{core}}}\n</html>');
insert into templates (code, template) values ('nnn-profile', '{{public_id}}
<h1>{{name}}</h1>

{{#pages}}
<h2><a href="{{long}}">{{short}}</a></h2>
{{/pages}}

<blockquote>{{thought}}</blockquote>

<h2>Location:</h2>
<p>
{{city}},
{{#state}}
{{state}},
{{/state}}
{{country}}
</p>

<h2>Professional title:</h2>
<p>{{title}}</p>

<h2>What do you do?</h2>
<p>{{liner}}</p>

<h2>Why?</h2>
<p>{{why}}</p>

<h2>What should we read?</h2>
<p>{{red}}</p>

<h2>URLs:</h2>
<ul>
{{#websites}}
<li><a href="{{url}}">{{url}}</a></li>
{{/websites}}
</ul>
');

select plan(3);

select results_eq('select uri from nnn.profiles()',
	$$values ('four'::char(4)), ('sevn'::char(4))$$,
	'uris sorted');

select is(body, '<html><title>DD now</title>
four
<h1>DD</h1>

<h2><a href="https://dd1.com/now">dd1.com/now</a></h2>
<h2><a href="https://dd2.com/now">dd2.com/now</a></h2>

<blockquote>thought4</blockquote>

<h2>Location:</h2>
<p>
Singapore,
Singapore
</p>

<h2>Professional title:</h2>
<p>title4</p>

<h2>What do you do?</h2>
<p>liner4</p>

<h2>Why?</h2>
<p>why4</p>

<h2>What should we read?</h2>
<p>red4</p>

<h2>URLs:</h2>
<ul>
<li><a href="https://dd1.com/">https://dd1.com/</a></li>
<li><a href="https://x.com/dd">https://x.com/dd</a></li>
<li><a href="https://bsky.app/dd">https://bsky.app/dd</a></li>
</ul>

</html>')
from nnn.profiles()
where uri = 'four';

select is(body, '<html><title>GG now</title>
sevn
<h1>GG</h1>

<h2><a href="https://gg.com/now">gg.com/now</a></h2>

<blockquote>thought7</blockquote>

<h2>Location:</h2>
<p>
Oxford,
England,
United Kingdom
</p>

<h2>Professional title:</h2>
<p>title7</p>

<h2>What do you do?</h2>
<p>liner7</p>

<h2>Why?</h2>
<p>why7</p>

<h2>What should we read?</h2>
<p>red7</p>

<h2>URLs:</h2>
<ul>
<li><a href="https://gg.com/">https://gg.com/</a></li>
<li><a href="https://facebook.com/gg">https://facebook.com/gg</a></li>
</ul>

</html>')
from nnn.profiles()
where uri = 'sevn';

