insert into people (id, name) values (0, 'robot');
insert into ats (email, person_id) values ('robot@ro.bot', 0);

insert into people (id, name, greeting) values (1, 'Jeff Lebowski', 'Dude');
insert into ats (email, person_id) values ('dude@du.de', 1);

insert into configs (k, v) values ('sig', 'signing off');

insert into formletters (id, title, subject, body) values (1, 'test', 'hi {greeting}', 'your id is {id} and name is {name}, {greeting}');

select setval('emails_id_seq', 1);

select plan(5);

select is(o.send_formletter(1, 1), 2);

select is(subject, 'hi Dude'),
	is(body, e'Hi Dude -\n\nyour id is 1 and name is Jeff Lebowski, Dude\n\n--\nsigning off'),
	is(their_email, 'dude@du.de'),
	is(their_name, 'Jeff Lebowski')
from emails where id = 2;

