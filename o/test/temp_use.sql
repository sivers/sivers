insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id) values ('a@a.com', 1);
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(8);

select is(1, count(*)::integer) from temps;

select is(person_id, 1),
	is(cookie, 'abcdefghijklmnopqrstuvwxyz012345')
from o.temp_use('abcdefghijklmnop', 1);

select is(0, count(*)::integer) from temps;

select is(person_id, null, 'only works once'),
	is(cookie, null)
from o.temp_use('abcdefghijklmnop', 1);

select is(person_id, null, 'wrong tempcode'),
	is(cookie, null)
from o.temp_use('XbXdXfXhXjXlXnXZ', 9);

