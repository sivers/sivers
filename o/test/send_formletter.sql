insert into people (id, name) values (0, 'robot');
insert into ats (email, person_id) values ('robot@ro.bot', 0);

insert into people (id, name, greeting) values (1, 'Jeff Lebowski', 'Dude');
insert into ats (email, person_id) values ('dude@du.de', 1);

insert into configs (k, v) values ('sig', 'signing off');

insert into now_pages (id, person_id, short, long) values (1, 1, 'a.com', 'https://a.com/');

insert into formletters (id, title, subject, body) values (1, 'test', 'hi {greeting}', 'your id is {id} and name is {name}, {greeting}');
insert into formletters (id, title, subject, body) values (24, 'now-check-gone', '{short} is gone?', 'your /now page is gone? {long}');

select setval('emails_id_seq', 1);

select plan(10);

select is(o.send_formletter(1, 1), 2);

select is(subject, 'hi Dude'),
	is(body, e'Hi Dude -\n\nyour id is 1 and name is Jeff Lebowski, Dude\n\n--\nsigning off'),
	is(their_email, 'dude@du.de'),
	is(their_name, 'Jeff Lebowski')
from emails where id = 2;

select is(o.send_formletter(1, 24), 3);
select is(subject, 'a.com is gone?'),
	is(body, e'Hi Dude -\n\nyour /now page is gone? https://a.com/\n\n--\nsigning off'),
	is(their_email, 'dude@du.de'),
	is(their_name, 'Jeff Lebowski')
from emails where id = 3;

