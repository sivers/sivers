insert into meetcats (id, display) values (3, 'Kolkata');

insert into people (id, name) values (1, 'Mrs. One');
insert into people (id, name) values (2, 'Mr. Two');

insert into meetings (id, meetcat, location, tzname, person_id, whatime) values (1, 3, 'Future Kolkata Café, fut.cat.in', 'Asia/Kolkata', 1, '2112-01-23 09:30:00+00');
insert into meetings (id, meetcat, location, tzname, person_id) values (2, 3, 'Future Kolkata Café, fut.cat.in', 'Asia/Kolkata', 2);

insert into meetavails (id, meetcat, location, tzname, startime) values (1, 3, 'Future Kolkata Café, fut.cat.in', 'Asia/Kolkata', '2112-01-23 05:30:00+00');
insert into meetavails (id, meetcat, location, tzname, startime, person_id, meeting_id) values (2, 3, 'Future Kolkata Café, fut.cat.in', 'Asia/Kolkata', '2112-01-23 09:30:00+00', 1, 1);
insert into meetavails (id, meetcat, location, tzname, startime) values (3, 3, 'Future Kolkata Café, fut.cat.in', 'Asia/Kolkata', '2112-01-23 15:30:00+00');

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
bigloc={{bigloc}}
{{#avails}}
 day={{day}}
 ymd={{ymd}}
 location={{location}}
 locahtml={{{locahtml}}}
{{#times}}
  id={{id}}
  start={{start}}
  startiso={{startiso}}
{{/times}}
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
location=Future Kolkata Café, fut.cat.in
when=15:00 PM Saturday  23 January
</body>')
from me.meet1('oooooooooooooooo');

select is(head, null),
	is(body, '<title>choose a time</title><body>
temp=tttttttttttttttt
name=Mr. Two
bigloc=Kolkata
 day=Saturday January 23
 ymd=2112-01-23
 location=Future Kolkata Café, fut.cat.in
 locahtml=Future Kolkata Café, <a href="https://fut.cat.in">fut.cat.in</a>
  id=1
  start=11AM
  startiso=2112-01-23T11:00
  id=3
  start=9PM
  startiso=2112-01-23T21:00
</body>')
from me.meet1('tttttttttttttttt');
