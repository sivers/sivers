insert into people (id, name) values (0, 'bot');
insert into people (id, name) values (1, 'a');
insert into people (id, name) values (2, 'b');
insert into people (id, name) values (3, 'c');

insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (2, 'two@two.two');
insert into ats (person_id, email) values (3, 'tri@tri.tri');

insert into admins (person_id) values (1);
insert into admin_auths (person_id, appcode) values (1, 'peep');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (1, 2, 'cat1', 0, '2025-10-27', 'two@two.two', 'b', 'subject1', 'body1');
insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (2, 2, 'cat1', 0, '2025-10-28', 'two@two.two', 'b', 'subject2', 'body2');
insert into emails (id, person_id, category, created_by, created_at, opened_at, opened_by, their_email, their_name, subject, body)
values (3, 3, 'cat2', 0, '2025-10-28', now(), 1, 'tri@tri.tri', 'c', 'subject3 is "open"', 'body3 is open');
insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (4, 3, 'cat2', 0, '2025-10-29', 'tri@tri.tri', 'c', 'subject4', 'body4');

select plan(14);

select is(body, null, 'bad cookie'),
	is(head, e'303\r\nLocation: /login')
from peep.email_open_next('aXaXaXaXaXaaXaXaXaaXaXaaXaaXaaXa', 'cat1');

select is(body, null, 'null cookie'),
	is(head, e'303\r\nLocation: /login')
from peep.email_open_next(null, 'cat1');

select is(body, null, 'next cat1 = 1'),
	is(head, e'303\r\nLocation: /email/1')
from peep.email_open_next('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'cat1');

select is(body, null, 'next cat1 = 2'),
	is(head, e'303\r\nLocation: /email/2')
from peep.email_open_next('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'cat1');

select is(body, null, 'no cat1 left'),
	is(head, e'303\r\nLocation: /')
from peep.email_open_next('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'cat1');

select is(body, null, 'next cat2 = 4'),
	is(head, e'303\r\nLocation: /email/4')
from peep.email_open_next('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'cat2');

select is(body, null, 'bad cat same as none left'),
	is(head, e'303\r\nLocation: /')
from peep.email_open_next('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'cat9');

