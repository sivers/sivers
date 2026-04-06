insert into people (id, name, lopass) values (1, 'One Person', 'aB3D');
insert into ats (person_id, email, listype) values (1, 'one@one.com', 'all');

insert into templates (code, template) values ('me-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('me-listform', 'id={{id}}
name={{name}}
lopass={{lopass}}');

select plan(4);

select is(head, e'303\r\nLocation: /contact'),
	is(body, null)
from me.list_form(1, 'xxxx');

select is(head, null),
	is(body, '<html>id=1
name=One Person
lopass=aB3D</html>')
from me.list_form(1, 'aB3D');

