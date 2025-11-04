insert into templates (code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-uninvited', '<h1>uninvited</h1>');
insert into templates (code, template) values ('mynow-checkemail', '<h1>check email</h1>');

insert into people (id, name) values (0, 'nobody');
insert into people (id, name) values (1, 'Al Member');
insert into ats (person_id, email, used) values (1, 'new@al.al', '2025-09-01');
insert into ats (person_id, email, used) values (1, 'old@al.al', '1999-12-31');
insert into now_pages (id, person_id, short, long) values (1, 1, 'al.al/now', 'https://al.al/now');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

insert into people (id, name) values (2, 'No');
insert into ats (person_id, email) values (2, 'no@no.no');

select plan(20);

select is(head, e'303\r\nLocation: /', 'correct cookie already? redirect home.'),
	is(body, null)
from mynow.authpost('abcdefghijklmnopqrstuvwxyz012345', 'does-not-matter@here.com');

select is(head, e'303\r\nLocation: /f?m=bad', 'bad email? f with message bad'),
	is(body, null)
from mynow.authpost(null, 'me@um');

select is(head, e'303\r\nLocation: /f?m=404', 'email not found? f with message 404'),
	is(body, null)
from mynow.authpost(null, 'never@before.seen');

select is(head, null, 'email found but uninvited? show page to say so'),
	is(body, '<html><h1>uninvited</h1></html>')
from mynow.authpost(null, 'no@no.no');

select is('new@al.al', o.email_for(1), 'new email is newest before login');

select is(head, null, 'good login! tempcode and check email'),
	is(body, '<html><h1>check email</h1></html>')
from mynow.authpost(null, 'old@al.al');

select is('old@al.al', o.email_for(1), 'using old email for login made it the newest one, so it will get the tempcode email');

select is(person_id, 1),
	is(category, 'templink'),
	is(closed_by, 0),
	is(their_email, 'old@al.al'),
	is(their_name, 'Al Member'),
	is(subject, 'your login link for my.nownownow.com'),
	ok(strpos(body, 'https://my.nownownow.com/e?t=') > 0),
	is(outgoing, null)
from emails order by id desc limit 1;

