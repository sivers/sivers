insert into templates (code, template) values ('mynow-headfoot', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-authform', '<h1>{{message}}</h1><form></form>');

insert into people (id, name) values (1, 'A');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(8);

select is(head, null),
	is(body, '<html><h1>Your email address?</h1><form></form></html>')
from mynow.authform(null, null);

select is(head, null),
	is(body, '<html><h1>Typo? Try again?</h1><form></form></html>')
from mynow.authform(null, 'bad');

select is(head, null),
	is(body, '<html><h1>Not found here. Got a different email?</h1><form></form></html>')
from mynow.authform(null, '404');

select is(head, e'303\r\nLocation: /'),
	is(body, null)
from mynow.authform('abcdefghijklmnopqrstuvwxyz012345', null);

