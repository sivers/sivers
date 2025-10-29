insert into templates values ('peep-wrap', '<main>{{{core}}}</main>');
insert into templates values ('loginform', '<form></form>');

select plan(2);

-- no variables, just static page
select is(head, null),
	is(body, '<main><form></form></main>')
from peep.loginform();


