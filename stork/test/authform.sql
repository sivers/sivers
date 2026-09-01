insert into templates (code, template) values ('stork-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('stork-authform', '<form></form>');

select plan(2);

select is(head, null),
	is(body, '<html><form></form></html>')
from stork.authform();

