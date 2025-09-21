insert into people (id, name) values (1, 'Admin');
insert into ats (email, person_id) values ('a@a.com', 1);

insert into people (id, name, greeting) values (2, 'Recipient', 'Reci-poo');
insert into ats (email, person_id, used) values ('b@b.net', 2, '2000-01-01 01:01:01');
insert into ats (email, person_id) values ('b@b.com', 2);

insert into emails(id, person_id, category, created_at, created_by, opened_at, opened_by, closed_at, closed_by, their_email, their_name, subject, body, message_id, outgoing)
values (1, 2, 'testing', now(), 1, now(), 1, now(), 1, 'b@b.net', 'Mister Recipent', 'reply to this', 'Hi. Please reply to this.', 'reply.to.this@b.net', false);
select setval('emails_id_seq', 1);

insert into configs (k, v) values ('sig', 'signing off');

select plan(21);

select is(o.email(1, 2, 'a subject', 'a body', null), 2);
select is(id, 2),
	is(person_id, 2),
	is(category, 'out'),
	is(outgoing, null),
	is(reference_id, null),
	is(their_email, 'b@b.com'),
	is(their_name, 'Recipient'),
	is(subject, 'a subject'),
	is(body, e'Hi Reci-poo -\n\na body\n\n--\nsigning off')
from emails where id = 2;

select is(category, 'testing') from emails where id = 1;

select is(o.email(1, 2, 're: reply to this', 'OK', 1), 3);
select is(id, 3),
	is(person_id, 2),
	is(category, 'testing'),
	is(outgoing, null),
	is(reference_id, 1),
	is(their_email, 'b@b.net'), -- the one they emailed from, though not newest
	is(their_name, 'Recipient'),
	is(subject, 're: reply to this'),
	is(body, e'Hi Reci-poo -\n\nOK\n\n--\nsigning off')
from emails where id = 3;

-- TODO: I thought it copied their old email back to them when replying

