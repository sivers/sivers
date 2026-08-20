insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-metat', '<h1>{{place}}</h1>
<p>{{thoughts}}</p>
{{#meetings}}
id:{{id}}
name:{{name}}
location:{{location}}
topics:{{topics}}
{{/meetings}}
');

insert into meetcats (id, display, thoughts) values (2, '2026-02 - Two Place', 'Wow this was great.');

insert into people (id, name) values (2, 'Mr. Two');
insert into people (id, name) values (4, 'Sir Four');

insert into meetings (id, meetcat, person_id, location, tzname, whatime, topics, notes) values (3, 2, 2, 'Two Hotel rooftop', 'America/Santiago', '2026-02-22 12:00:00+00', 'two topics', 'two notes');
insert into meetings (id, meetcat, person_id, location, tzname, whatime, topics, notes) values (4, 2, 4, 'Two Hotel lobby', 'America/Santiago', '2026-02-04 12:00:00+00', 'topics four', 'notes four');

select plan(1);
select is(body, '<title>2026-02 - Two Place - Derek Sivers meetings</title><body><h1>2026-02 - Two Place</h1>
<p>Wow this was great.</p>
id:4
name:Sir Four
location:Two Hotel lobby
topics:topics four
id:3
name:Mr. Two
location:Two Hotel rooftop
topics:two topics
</body>')
from me.metat(2);
