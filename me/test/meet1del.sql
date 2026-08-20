insert into meetcats (id) values (3);
insert into meetcats (id) values (4);

insert into people (id, name, greeting) values (1, 'Mrs. One', 'Onesey');
insert into people (id, name, greeting) values (2, 'Mr. Two', 'Twobody');
insert into people (id, name, greeting) values (3, 'Three PO', '3PO');

insert into meetings (id, meetcat, person_id, location, tzname, whatime) values (1, 3, 1, 'Future Kolkata', 'Asia/Kolkata', '2112-01-23 10:00:00+00');
insert into meetings (id, meetcat, person_id, location, tzname) values (2, 3, 2, 'Future Kolkata', 'Asia/Kolkata');

insert into meetavails (id, meetcat, location, tzname, startime, stoptime) values (1, 3, 'Future Kolkata', 'Asia/Kolkata', '2112-01-23 08:00:00+00', '2112-01-23 09:00:00+00');
insert into meetavails (id, meetcat, location, tzname, startime, stoptime, person_id, meeting_id) values (2, 3, 'Future Kolkata', 'Asia/Kolkata', '2112-01-23 10:00:00+00', '2112-01-23 11:00:00+00', 1, 1);

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

