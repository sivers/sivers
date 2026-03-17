insert into countries values ('GB', 'United Kingdom');

insert into people (id, name) values (0, 'bot');
insert into people (id, name) values (1, 'a');
insert into people (id, name, greeting, company, city, state, country, phone, notes, categorize_as)
values (2, 'Big Ben', 'Biggie', 'Palace Ltd', 'London', 'ENG', 'GB', '+44 55443322', 'knows time', 'catas');

insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email, used, listype) values (2, 'two@two.two', '2025-10-29', 'none');
insert into ats (person_id, email, used, listype) values (2, 'list@two.two', null, 'all');
insert into ats (person_id, email, used, listype) values (2, 'old@two.two', '1999-12-31', null);

insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into emails (id, person_id, category,
	created_by, created_at, opened_by, opened_at, closed_by, closed_at,
	their_email, their_name, subject, body)
values (1, 2, 'cat1',
	0, '2024-01-01', 1, '2024-01-01', 1, '2024-01-01',
	'two@two.two', 'Big Ben', 'old subject1', 'body1');
insert into emails (id, person_id, category,
	created_by, created_at, opened_by, opened_at, closed_by, closed_at,
	their_email, their_name, subject, body)
values (2, 2, 'cat1',
	0, '2025-01-01', 1, '2025-01-01', 1, '2025-01-01',
	'two@two.two', 'Big Ben', 'old subject2', 'body2');
insert into emails (id, person_id, category,
	created_by, created_at, opened_by, opened_at, closed_by, closed_at,
	their_email, their_name, subject, body,
	headers, message_id)
values (3, 2, 'cat1',
	0, '2025-10-29', null, null, null, null,
	'two@two.two', 'Big Ben', 'new subject', 'new body',
	e'In-Reply-To: <x.x>\nReferences: <x.x>', 'someid@gmail');
insert into emails (id, category, their_email, their_name) values (4, 'unknown', 'no@body.knows', 'Mr. Nobody');
insert into emails (id, person_id, reference_id, category,
	created_by, created_at, opened_by, opened_at, closed_by, closed_at,
	their_email, their_name, subject, body, outgoing)
values (5, 2, 1, 'cat1',
	1, '2024-01-02', 1, '2024-01-02', 1, '2024-01-02',
	'two@two.two', 'Big Ben', 're: old subject1', 'my reply to # 1', 't');
insert into emails (id, person_id, reference_id, category,
	created_by, created_at, opened_by, opened_at, closed_by, closed_at,
	their_email, their_name, subject, body, outgoing)
values (6, 2, 2, 'cat1',
	1, '2025-01-02', 1, '2025-01-02', 1, '2025-01-02',
	'two@two.two', 'Big Ben', 're: old subject2', 'queued reply to # 2', null);

insert into attachments (id, email_id, filename) values (1, 3, 'file1.jpg');
insert into attachments (id, email_id, filename) values (2, 3, 'file2.pdf');

insert into urls (id, person_id, url, main) values (1, 2, 'https://z.com/two', null);
insert into urls (id, person_id, url, main) values (2, 2, 'https://two.two/', true);
insert into urls (id, person_id, url, main) values (3, 2, 'https://a.com/two', false);

insert into ptags (person_id, tag, very, created_at) values (2, 'big', true, '1999-12-31');
insert into ptags (person_id, tag, very, created_at) values (2, 'old', null, '2000-01-01');
insert into ptags (person_id, tag, very, created_at) values (2, 'fast', false, '2001-01-01');

insert into stats (id, person_id, statkey, statvalue, created_at) values (1, 2, 'lang', 'en', '1999-12-31');
insert into stats (id, person_id, statkey, statvalue, created_at) values (2, 2, 'currency', 'GBP', '2025-10-01');

insert into formletters (id, accesskey, title, explanation, body) values (1, 'z', 'z title', 'z explanation', 'z body');
insert into formletters (id, accesskey, title, explanation, body) values (2, 'a', 'a title', 'a explanation', 'a body');
insert into formletters (id, title, explanation, body) values (3, 'no show', 'because', 'no accesskey');
insert into formletters (id, accesskey, title, explanation, body) values (4, 'g', 'g title', 'g explanation', 'g body');

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-email', '
email {{email.id}}
person_id {{email.person_id}}
category {{email.category}}
created_by {{email.created_by}}
created_at {{email.created_at}}
opened_by {{email.opened_by}}
opened_at {{email.opened_at}}
closed_by {{email.closed_by}}
closed_at {{email.closed_at}}
their_email {{email.their_email}}
their_name {{email.their_name}}
subject {{email.subject}}
body {{email.body}}
message_id {{email.message_id}}
headers {{email.headers}}
outgoing {{email.outgoing}}

person.id {{person.id}}
name {{person.name}}
greeting {{person.greeting}}
company {{person.company}}
city {{person.city}}
state {{person.state}}
country {{person.country}}
phone {{person.phone}}
notes {{person.notes}}
categorize_as {{person.categorize_as}}

{{#ats}}
ats: email={{email}}, used={{used}}, listype={{listype}}
{{/ats}}

{{#emails}}
emails: id={{id}}, created_at={{created_at}}, subject={{subject}}
{{/emails}}

{{#urls}}
urls: id={{id}}, url={{url}}, main={{main}}
{{/urls}}

{{#tags}}
tags: tag={{tag}}, very={{very}}, created_at={{created_at}}
{{/tags}}

{{#stats}}
stats: id={{id}}, statkey={{statkey}}, statvalue={{statvalue}}, created_at={{created_at}}
{{/stats}}

{{#formletters}}
formletters: id={{id}}, accesskey={{accesskey}}, title={{title}}, explanation={{explanation}}, body={{body}}
{{/formletters}}
');

select plan(14);

select is(head, e'303\r\nLocation: /login'),
	is(body, null, 'bad cookie')
from peep.email_view('aaaaaaaXXaXXaaXaXaaaXXaaaaXaaaaa', 3);

select is(head, e'303\r\nLocation: /login'),
	is(body, null, 'null cookie')
from peep.email_view(null, 3);

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'bad email id')
from peep.email_view('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 99);

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'email with no person')
from peep.email_view('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 4);

select is(head, null),
	is(body, '<html>
email 3
person_id 2
category cat1
created_by 0
created_at 2025-10-29
opened_by 
opened_at 
closed_by 
closed_at 
their_email two@two.two
their_name Big Ben
subject new subject
body new body
message_id someid@gmail
headers In-Reply-To: &lt;x.x&gt;
References: &lt;x.x&gt;
outgoing false

person.id 2
name Big Ben
greeting Biggie
company Palace Ltd
city London
state ENG
country GB
phone +44 55443322
notes knows time
categorize_as catas

ats: email=two@two.two, used=2025-10-29, listype=none
ats: email=old@two.two, used=1999-12-31, listype=
ats: email=list@two.two, used=, listype=all

emails: id=6, created_at=2025-01-02, subject=re: old subject2
emails: id=5, created_at=2024-01-02, subject=re: old subject1
emails: id=3, created_at=2025-10-29, subject=new subject
emails: id=2, created_at=2025-01-01, subject=old subject2
emails: id=1, created_at=2024-01-01, subject=old subject1

urls: id=2, url=https://two.two/, main=true
urls: id=3, url=https://a.com/two, main=false
urls: id=1, url=https://z.com/two, main=

tags: tag=big, very=true, created_at=1999-12-31
tags: tag=old, very=, created_at=2000-01-01
tags: tag=fast, very=false, created_at=2001-01-01

stats: id=1, statkey=lang, statvalue=en, created_at=1999-12-31
stats: id=2, statkey=currency, statvalue=GBP, created_at=2025-10-01

formletters: id=2, accesskey=a, title=a title, explanation=a explanation, body=a body
formletters: id=4, accesskey=g, title=g title, explanation=g explanation, body=g body
formletters: id=1, accesskey=z, title=z title, explanation=z explanation, body=z body
</html>')
from peep.email_view('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 3);

select is(opened_by, 1, 'updated opened_by'),
	isnt(opened_at, null, 'updated opened_at'),
	is(closed_by, null, 'did not change closed_by'),
	is(closed_at, null, 'did not change closed_at')
from emails where id = 3;


