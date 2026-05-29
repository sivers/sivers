insert into meetwheres (id, location, tzname) values (3, 'Future Kolkata', 'Asia/Kolkata');

insert into people (id, name) values (1, 'Mrs. One');
insert into people (id, name) values (2, 'Mr. Two');

insert into meetings (id, where_id, person_id, whatime) values (1, 3, 1, '2112-01-23 10:00:00+00');
insert into meetings (id, where_id, person_id) values (2, 3, 2);

insert into meetavails (id, where_id, startime, stoptime) values (1, 3, '2112-01-23 08:00:00+00', '2112-01-23 09:00:00+00');
insert into meetavails (id, where_id, startime, stoptime, person_id, meeting_id) values (2, 3, '2112-01-23 10:00:00+00', '2112-01-23 11:00:00+00', 1, 1);
insert into meetavails (id, where_id, startime, stoptime) values (3, 3, '2112-01-23 12:00:00+00', '2112-01-23 13:00:00+00');

insert into temps (temp, person_id) values ('oooooooooooooooo', 1);
insert into temps (temp, person_id) values ('tttttttttttttttt', 2);

insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-meet1-change', '
temp={{temp}}
name={{name}}
location={{location}}
when={{when}}
');
insert into templates (code, template) values ('me-meet1-avails', '
temp={{temp}}
name={{name}}
location={{location}}
{{#avails}}
id={{id}}
start={{start}}
stop={{stop}}
{{/avails}}
');

select plan(6);

select is(head, e'303\r\nLocation: /sorry?for=badurlid'),
	is(body, null)
from me.meet1('BadTempCodeValue');

select is(head, null),
	is(body, '<title>your chosen time</title><body>
temp=oooooooooooooooo
name=Mrs. One
location=Future Kolkata
when=15:30 PM Saturday  23 January
</body>')
from me.meet1('oooooooooooooooo');

select is(head, null),
	is(body, '<title>choose a time</title><body>
temp=tttttttttttttttt
name=Mr. Two
location=Future Kolkata
id=1
start=13:30 PM Saturday  23 January
stop=14:30 PM
id=3
start=17:30 PM Saturday  23 January
stop=18:30 PM
</body>')
from me.meet1('tttttttttttttttt');
