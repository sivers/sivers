insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-met1', '<h1>{{name}}</h1>
where_id:{{where_id}}
location:{{location}}
display:{{display}}
whatime:{{whatime}}
notes:{{notes}}
{{#urls}}
url:{{url}}
{{/urls}}
');
insert into meetwheres (id, location, display) values (1, 'One Hotel', '2025-01 - One Place');

insert into people (id, name) values (1, 'Mrs. One');

insert into urls (person_id, url, main) values (1, 'https://last.url', null);
insert into urls (person_id, url, main) values (1, 'https://first.url', true);
insert into urls (person_id, url, main) values (1, 'https://middle.url', false);

insert into meetings (id, where_id, person_id, whatime, topics, notes) values (1, 1, 1, '2025-01-15 12:00:00+00', 'topics one', 'notes one');

select plan(1);
select is(body, '<title>Mrs. One met with Derek Sivers</title><body><h1>Mrs. One</h1>
where_id:1
location:One Hotel
display:2025-01 - One Place
whatime:2025-01-15T12:00:00+00:00
notes:notes one
url:https://first.url
url:https://middle.url
url:https://last.url
</body>')
from me.met1(1);
