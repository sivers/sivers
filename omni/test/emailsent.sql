insert into people (id, name) values (1, 'Admin');
insert into ats (email, person_id) values ('a@a.com', 1);

insert into people (id, name, greeting) values (2, 'Recipient', 'Reci-poo');
insert into ats (email, person_id, used) values ('b@b.net', 2, '2000-01-01 01:01:01');
insert into ats (email, person_id) values ('b@b.com', 2);

insert into emails(id, person_id, category, created_at, created_by, opened_at, opened_by, closed_at, closed_by, their_email, their_name, subject, body, message_id, outgoing)
values (1, 2, 'testing', now(), 1, now(), 1, now(), 1, 'b@b.net', 'Mister Recipent', 'reply to this', 'Hi. Please reply to this.', 'reply.to.this@b.net', null);

select plan(2);

select is(outgoing, null) from emails where id = 1;
select o.emailsent(1);
select is(outgoing, true) from emails where id = 1;

