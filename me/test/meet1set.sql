insert into meetwheres (id, location, tzname) values (3, 'Future Kolkata', 'Asia/Kolkata');
insert into meetwheres (id, location, tzname) values (4, 'Future Neverland', 'America/Santiago');

insert into configs (k, v) values ('sig', 'emailsighere');
insert into people (id, name) values (0, 'robot');
insert into people (id, name, greeting) values (1, 'Mrs. One', 'Onesey');
insert into people (id, name, greeting) values (2, 'Mr. Two', 'Twobody');
insert into ats (person_id, email) values (0, 'ro@bo.tt');
insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (2, 'two@two.two');

insert into meetings (id, where_id, person_id, whatime) values (1, 3, 1, '2112-01-23 10:00:00+00');
insert into meetings (id, where_id, person_id) values (2, 3, 2);

insert into meetavails (id, where_id, startime, stoptime) values (1, 3, '2112-01-23 08:00:00+00', '2112-01-23 09:00:00+00');
insert into meetavails (id, where_id, startime, stoptime, person_id, meeting_id) values (2, 3, '2112-01-23 10:00:00+00', '2112-01-23 11:00:00+00', 1, 1);
insert into meetavails (id, where_id, startime, stoptime) values (3, 3, '2112-01-23 12:00:00+00', '2112-01-23 13:00:00+00');
insert into meetavails (id, where_id, startime, stoptime) values (4, 4, '2199-11-22 12:00:00+00', '2199-11-22 13:00:00+00');

insert into temps (temp, person_id) values ('oooooooooooooooo', 1);
insert into temps (temp, person_id) values ('tttttttttttttttt', 2);

select plan(14);

select is(head, e'303\r\nLocation: /sorry?for=badurlid')
from me.meet1set('BadTempCodeValue', 4);

select is(head, e'303\r\nLocation: /sorry', 'wheres mismatch')
from me.meet1set('tttttttttttttttt', 4);

select is(head, e'303\r\nLocation: /thanks?for=done', 'chose same again')
from me.meet1set('oooooooooooooooo', 2);

select is(head, e'303\r\nLocation: /meet1?t=oooooooooooooooo', 'chose different')
from me.meet1set('oooooooooooooooo', 3);

select is(head, e'303\r\nLocation: /thanks?for=done', 'chose wisely')
from me.meet1set('tttttttttttttttt', 1);

select is(person_id, 2, 'meetavails updated'),
	is(meeting_id, 2)
from meetavails where id = 1;

select is(whatime, '2112-01-23 08:00:00+00', 'meetings updated')
from meetings where id = 2;

select is(head, e'303\r\nLocation: /thanks?for=done', 'duplicate no dupe email')
from me.meet1set('tttttttttttttttt', 1);

select is(count(*), 1::bigint, 'only one email') from emails;

select is(their_email, 'two@two.two', 'email address'),
	is(their_name, 'Mr. Two', 'name'),
	is(subject, '13:30 PM Saturday  23 January at Future Kolkata', 'subject place and time'),
	is(body, 'Hi Twobody -

I look forward to meeting you. Thanks for picking a time.

WHERE: Future Kolkata

WHEN: 13:30 PM Saturday  23 January

If you need to change or cancel, just go back to https://sive.rs/meet1?t=tttttttttttttttt

--
emailsighere', 'body place and time')
from emails order by id desc limit 1;

