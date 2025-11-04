-- very ugly tests
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

insert into templates (code, template) values ('nnn-wrap', e'<html><title>{{pagetitle}}</title>\n{{{core}}}\n</html>');
insert into templates (code, template) values ('nnn-place', '<header>
<h1><a href="/about">/now pages</a> in {{placename}}</h1>
</header>
<main>

{{#profiles1}}
<ul class="photos">
{{#profiles1}}
<li>
<a href="/p/{{public_id}}"><img src="https://m.nownownow.com/{{public_id}}.webp" width="300" height="300" alt="{{name}}" loading="lazy"></a>
<h2><a href="/p/{{public_id}}">{{name}}</a></h2>
{{#pages}}
<h3><a href="{{long}}">{{short}}</a></h3>
{{/pages}}
<p>{{title}}</p>
</li>
{{/profiles1}}
</ul>
{{/profiles1}}

{{#profiles2}}
<hr>
(missing profile questions:)
<ul class="photos">
{{#profiles2}}
<li>
<a href="/p/{{public_id}}"><img src="https://m.nownownow.com/{{public_id}}.webp" width="300" height="300" alt="{{name}}" loading="lazy"></a>
<h2>{{name}}</h2>
{{#pages}}
<h3><a href="{{long}}">{{short}}</a></h3>
{{/pages}}
</li>
{{/profiles2}}
</ul>
{{/profiles2}}

{{#profiles3}}
<hr>
(missing photo:)
<ul class="nophotos">
{{#profiles3}}
<li>
<h2>{{name}}</h2>
<p>{{title}}</p>
{{#pages}}
<h3><a href="{{long}}">{{short}}</a></h3>
{{/pages}}
</li>
{{/profiles3}}
</ul>
{{/profiles3}}

{{#profiles4}}
<hr>
(missing photo and profile questions:)
<ul class="nophotos">
{{#profiles4}}
<li>
<h2>{{name}}</h2>
{{#pages}}
<h3><a href="{{long}}">{{short}}</a></h3>
{{/pages}}
</li>
{{/profiles4}}
</ul>
{{/profiles4}}

</main>
<footer>
Last update: <time datetime="{{date}}">{{date}}</time>
</footer>');

select plan(8);

select	is(substr(body, 0, 59),
	'<html><title>/now pages in England, United Kingdom</title>',
	'title'),

	is(substr(body, strpos(body, '<time'), 45),
	'<time datetime="' || current_date || '">' || current_date || '</time>',
	'date'),

	is(substr(body, strpos(body, '<ul class="photos">'), 254),
'<ul class="photos">
<li>
<a href="/p/sevn"><img src="https://m.nownownow.com/sevn.webp" width="300" height="300" alt="GG" loading="lazy"></a>
<h2><a href="/p/sevn">GG</a></h2>
<h3><a href="https://gg.com/now">gg.com/now</a></h3>
<p>title7</p>
</li>
</ul>', '7 has it all'),

	is(substr(body, strpos(body, '(missing profile q'), 247),
'(missing profile questions:)
<ul class="photos">
<li>
<a href="/p/six6"><img src="https://m.nownownow.com/six6.webp" width="300" height="300" alt="FF" loading="lazy"></a>
<h2>FF</h2>
<h3><a href="https://ff.com/now">ff.com/now</a></h3>
</li>
</ul>', '6 has photo missing q'),

	is(substr(body, strpos(body, '<ul class="nophoto'), 103),
'<ul class="nophotos">
<li>
<h2>HH</h2>
<h3><a href="https://hh.com/now">hh.com/now</a></h3>
</li>
</ul>', '8 no profile no photo')

from nnn.place('GB', 'ENG');

select	is(substr(body, 0, 45),
	'<html><title>/now pages in Singapore</title>',
	'SG title'),

	is(substr(body, strpos(body, '<ul class="photos">'), 254),
'<ul class="photos">
<li>
<a href="/p/four"><img src="https://m.nownownow.com/four.webp" width="300" height="300" alt="DD" loading="lazy"></a>
<h2><a href="/p/four">DD</a></h2>
<h3><a href="https://dd.com/now">dd.com/now</a></h3>
<p>title4</p>
</li>
</ul>', '4 has it all'),

	is(substr(body, strpos(body, '(missing photo'), 134),
'(missing photo:)
<ul class="nophotos">
<li>
<h2>EE</h2>
<p>title5</p>
<h3><a href="https://ee.com/now">ee.com/now</a></h3>
</li>
</ul>', '5 no photo yes title')

from nnn.place('SG', null);

