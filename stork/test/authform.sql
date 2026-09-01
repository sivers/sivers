insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-authform', '<form></form>');

select plan(2);

select is(head, null),
	is(body, '<html><form></form></html>')
from storm.authform();

