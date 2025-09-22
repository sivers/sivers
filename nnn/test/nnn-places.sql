insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('US', 'OR', 'Oregon');
insert into states (country, code, name) values ('US', 'CA', 'California');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');

insert into people (id, name, state, country) values (1, 'AA', 'OR', 'US');
insert into people (id, name, state, country) values (2, 'BB', 'CA', 'US');
insert into people (id, name, state, country) values (3, 'CC', 'CA', 'US');
insert into people (id, name, state, country) values (4, 'DD', null, 'SG');
insert into people (id, name, state, country) values (5, 'EE', 'Singapore', 'SG');
insert into people (id, name, state, country) values (6, 'FF', 'ENG', 'GB');
insert into people (id, name, state, country) values (7, 'GG', 'ENG', 'GB');
insert into people (id, name, state, country) values (8, 'HH', 'ENG', 'GB');

insert into now_profiles (id) values (1);
insert into now_profiles (id) values (2);
insert into now_profiles (id) values (3);
insert into now_profiles (id) values (4);
insert into now_profiles (id) values (5);
insert into now_profiles (id) values (6);
insert into now_profiles (id) values (7);
insert into now_profiles (id) values (8);

insert into templates (code, template) values ('nnn-wrap', e'<html><title>{{pagetitle}}</title>\n{{{core}}}\n</html>');
insert into templates (code, template) values ('nnn-home', '{{#places}}
<li><a href="/{{url}}">{{name}}</a> ({{count}})</li>
{{/places}}
date:{{date}}');

select plan(2);

select matches(body, '<html><title>personal websites with a /now page</title>
<li><a href="/GB-ENG">GB: England</a> \(3\)</li>
<li><a href="/SG">Singapore</a> \(2\)</li>
<li><a href="/US-CA">US: California</a> \(2\)</li>
<li><a href="/US-OR">US: Oregon</a> \(1\)</li>
date:20[0-9]{2}-[0-9]{2}-[0-9]{2}
</html>', 'body')
from nnn.places();

select is(urls, array['GB-ENG', 'SG', 'US-CA', 'US-OR'], 'sorted urls') from nnn.places();
