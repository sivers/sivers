insert into templates (code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-authform', '<h1>{{message}}</h1><form></form>');

insert into people (id, name) values (1, 'A');
insert into now_pages (person_id, long) values (1, 'https://yes.com/now');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(8);

select is(head, null, 'no cookie no message? just ask email'),
	is(body, '<html><h1>Your email address?</h1><form></form></html>')
from mynow.authform(null, null);

select is(head, null, 'no cookie bad message? say try again'),
	is(body, '<html><h1>Typo? Try again?</h1><form></form></html>')
from mynow.authform(null, 'bad');

select is(head, null, 'no cookie 404 message? say not found'),
	is(body, '<html><h1>Not found here. Got a different email?</h1><form></form></html>')
from mynow.authform(null, '404');

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'login cookie already? send home')
from mynow.authform('abcdefghijklmnopqrstuvwxyz012345', null);

