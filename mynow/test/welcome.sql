insert into templates(code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates(code, template) values ('mynow-authform', '{{message}} form');
insert into templates(code, template) values ('mynow-welcome', '{{name}} form t={{temp}} p={{person_id}}');

insert into people (id, name) values (1, 'Person A');
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

select plan(6);

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'has cookie already')
from mynow.welcome('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'abcdefghijklmnop');

select is(head, null, 'bad tempcode'),
	is(body, '<html>Let’s email you a new login link form</html>')
from mynow.welcome(null, 'nnnnnnnnnnnnnnnn');

select is(head, null, 'good'),
	is(body, '<html>Person A form t=abcdefghijklmnop p=1</html>')
from mynow.welcome(null, 'abcdefghijklmnop');

