insert into meetwheres (id, location, tzname) values (3, 'Future Kolkata', 'Asia/Kolkata');
insert into meetwheres (id, location, tzname) values (4, 'Future Neverland', 'America/Santiago');

insert into people (id, name, greeting) values (1, 'Mrs. One', 'Onesey');
insert into people (id, name, greeting) values (2, 'Mr. Two', 'Twobody');
insert into people (id, name, greeting) values (3, 'Three PO', '3PO');

insert into meetings (id, where_id, person_id, whatime) values (1, 3, 1, '2112-01-23 10:00:00+00');
insert into meetings (id, where_id, person_id) values (2, 3, 2);

insert into meetavails (id, where_id, startime, stoptime) values (1, 3, '2112-01-23 08:00:00+00', '2112-01-23 09:00:00+00');
insert into meetavails (id, where_id, startime, stoptime, person_id, meeting_id) values (2, 3, '2112-01-23 10:00:00+00', '2112-01-23 11:00:00+00', 1, 1);

insert into temps (temp, person_id) values ('oooooooooooooooo', 1);
insert into temps (temp, person_id) values ('tttttttttttttttt', 2);
insert into temps (temp, person_id) values ('eeeeeeeeeeeeeeee', 3);

select plan(10);

select is(head, e'303\r\nLocation: /sorry?for=badurlid', 'not temp')
from me.meet1del('BadTempCodeValue');

select is(head, e'303\r\nLocation: /sorry?for=badurlid', 'not invited')
from me.meet1del('eeeeeeeeeeeeeeee');

select is(head, e'303\r\nLocation: /meet1?t=tttttttttttttttt', 'other person')
from me.meet1del('tttttttttttttttt');

select is(whatime, '2112-01-23 10:00:00+00', 'whatime unchanged')
from meetings where id = 1;

select is(person_id, 1, 'meetavails unchanged'),
	is(meeting_id, 1)
from meetavails where id = 2;

select is(head, e'303\r\nLocation: /meet1?t=oooooooooooooooo', 'deleted')
from me.meet1del('oooooooooooooooo');

select is(whatime, null, 'whatime erased')
from meetings where id = 1;

select is(person_id, null, 'meetavail erased'),
	is(meeting_id, null)
from meetavails where id = 2;

