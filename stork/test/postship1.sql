insert into templates (code, template) values ('stork-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('stork-postship1', 'upload form');

select plan(2);

select is(head, null),
	is(body, '<html>upload form</html>')
from stork.postship1();

