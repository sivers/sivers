insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-metat', '<h1>{{place}}</h1>
<h2>{{location}}</h2>
<p>{{thoughts}}</p>
{{#meetings}}
id:{{id}}
name:{{name}}
topics:{{topics}}
{{/meetings}}
');

insert into meetwheres (id, location, display, thoughts) values (2, 'Two Hotel', '2026-02 - Two Place', 'Wow this was great.');

insert into people (id, name) values (2, 'Mr. Two');
insert into people (id, name) values (4, 'Sir Four');

insert into meetings (id, where_id, person_id, whatime, topics, notes) values (3, 2, 2, '2026-02-22 12:00:00+00', 'two topics', 'two notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (4, 2, 4, '2026-02-04 12:00:00+00', 'topics four', 'notes four');

select plan(1);
select is(body, '<title>2026-02 - Two Place - Derek Sivers meetings</title><body><h1>2026-02 - Two Place</h1>
<h2>Two Hotel</h2>
<p>Wow this was great.</p>
id:4
name:Sir Four
topics:topics four
id:3
name:Mr. Two
topics:two topics
</body>')
from me.metat(2);
