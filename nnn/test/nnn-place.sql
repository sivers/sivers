insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');

insert into people (id, name, state, country) values (4, 'DD', null, 'SG');
insert into people (id, name, state, country) values (5, 'EE', 'Singapore', 'SG');
insert into people (id, name, state, country) values (6, 'FF', 'ENG', 'GB');
insert into people (id, name, state, country) values (7, 'GG', 'ENG', 'GB');
insert into people (id, name, state, country) values (8, 'HH', 'ENG', 'GB');

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

select plan(1);

select matches(body, 'Last update: <time datetime="date:20[0-9]{2}-[0-9]{2}-[0-9]{2} </html>', 'body')
from nnn.place();

