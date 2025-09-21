insert into people (id, name) values (0, 'nobody');
insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id) values ('a@a.com', 1);
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);

insert into temps(temp, new_email, new_name) values ('newNEWnewNEWnew1', 'new@new.nu', 'New Person');

select plan(20);

select is(id, null) from o.temp_email(null, 'y.com');
select is(id, null) from o.temp_email('XbXdXfXhXjXlXnXp', 'y.com');

select ok(id > 0) from o.temp_email('abcdefghijklmnop', 'y.com');
select is(person_id, 1),
	is(category, 'templink'),
	is(closed_by, 0),
	is(their_email, 'a@a.com'),
	is(their_name, 'Person A'),
	is(subject, 'your login link for y.com'),
	ok(strpos(body, 'https://y.com/e?t=abcdefghijklmnop') > 0),
	is(outgoing, null)
from emails order by id desc limit 1;

select ok(id > 0) from o.temp_email('newNEWnewNEWnew1', 'y.com');
select is(person_id, null),
	is(category, 'templink'),
	is(closed_by, 0),
	is(their_email, 'new@new.nu'),
	is(their_name, 'New Person'),
	is(subject, 'your login link for y.com'),
	ok(strpos(body, 'https://y.com/e?t=newNEWnewNEWnew1') > 0),
	is(outgoing, null)
from emails order by id desc limit 1;

