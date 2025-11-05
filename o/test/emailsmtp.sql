insert into people (id, name) values (1, 'Admin');
insert into ats (email, person_id) values ('a@a.com', 1);

insert into people (id, name, greeting) values (2, 'Recipient', 'Reci-poo');
insert into ats (email, person_id, used) values ('b@b.net', 2, '2000-01-01 01:01:01');
insert into ats (email, person_id) values ('b@b.com', 2);

insert into emails(id, person_id, category, created_at, created_by, opened_at, opened_by, closed_at, closed_by, their_email, their_name, subject, body, message_id, outgoing)
values (1, 2, 'testing', now(), 1, now(), 1, now(), 1, 'b@b.net', 'Mister Recipent', 'reply to this', 'Hi. Please reply to this.', 'reply.to.this@b.net', false);
insert into emails(id, reference_id, person_id, category, created_at, created_by, opened_at, opened_by, closed_at, closed_by, their_email, their_name, subject, body, message_id, outgoing)
values (2, 1, 2, 'testing', now(), 1, now(), 1, now(), 1, 'b@b.net', 'Recipent', 're: reply to this', e'Hi Reci-poo -\n\nOK\n\n--\nsigning off', '12345@sive.rs', null);

select plan(15);

select is(mailfrom, 'd@sive.rs'),  -- hard-coded for now, since it's only me
	is(rcptto, 'b@b.net'),
	is((string_to_array(msg, e'\r\n'))[1], 'From: Derek Sivers <d@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[2], 'To: Recipent <b@b.net>'),
	is((string_to_array(msg, e'\r\n'))[3], 'Subject: re: reply to this'),
	-- line 4 is date, changes every time, nevermind testing
	is((string_to_array(msg, e'\r\n'))[5], 'Message-ID: <12345@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[6], 'In-Reply-To: <reply.to.this@b.net>'),
	is((string_to_array(msg, e'\r\n'))[7], 'References: <reply.to.this@b.net>'),
	is((string_to_array(msg, e'\r\n'))[8], 'MIME-Version: 1.0'),
	is((string_to_array(msg, e'\r\n'))[9], 'Content-Type: text/plain; charset=UTF-8'),
	is((string_to_array(msg, e'\r\n'))[10], 'Content-Transfer-Encoding: 8bit'),
	is(substring(msg from (position('Hi Reci' in msg))),
		e'Hi Reci-poo -\r\n\r\nOK\r\n\r\n--\r\nsigning off\r\n\r\n> Hi. Please reply to this.\r\n')
from o.emailsmtp(2);

update emails set outgoing = true where id = 2;

select is(mailfrom, null),
	is(rcptto, null),
	is(msg, null, 'will not send already sent')
from o.emailsmtp(2);

