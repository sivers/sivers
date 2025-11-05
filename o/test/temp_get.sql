insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id) values ('a@a.com', 1);
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);

insert into people (id, name) values (2, 'Person B');
insert into ats (email, person_id) values ('b@b.com', 2);
insert into temps(temp, person_id, expires) values ('ABCDEFGHIJKLMNOP', 2, '2020-01-01 00:01:06+12');

select setval('people_id_seq', 2);  -- new ID will be 3
insert into temps(temp, new_email, new_name) values ('aa00bb11cc22dd33', 'nu@nu.nu', 'Total Stranger');

select plan(22);

select is(person_id, 1),
	is(name, 'Person A'),
	is(email, 'a@a.com'),
	is(temp, 'abcdefghijklmnop')
from o.temp_get_id(1);

select is_empty('select * from o.temp_get_id(2)', 'not found because expired');

select is_empty('select * from o.temp_get(''zzzzzzzzzzzzzzzz'')', 'wrong code');

select is_empty('select * from o.temp_get(''ABCDEFGHIJKLMNOP'')', 'right code but expired');

select is(person_id, 1),
	is(name, 'Person A'),
	is(email, 'a@a.com'),
	is(temp, 'abcdefghijklmnop')
from o.temp_get('abcdefghijklmnop');

select is(temp, 'abcdefghijklmnop', 'temp_get does not delete the temp code')
from o.temp_get('abcdefghijklmnop');

select is(person_id, null, 'new person not added to people during temp_get_only'),
	is(name, 'Total Stranger'),
	is(email, 'nu@nu.nu'),
	is(temp, 'aa00bb11cc22dd33')
from o.temp_get_only('aa00bb11cc22dd33');

select is(person_id, 3, 'new person added to people during temp_get'),
	is(name, 'Total Stranger'),
	is(email, 'nu@nu.nu'),
	is(temp, 'aa00bb11cc22dd33')
from o.temp_get('aa00bb11cc22dd33');

select is(person_id, 3, 'can still auth new person now in people'),
	is(temp, 'aa00bb11cc22dd33')
from o.temp_get('aa00bb11cc22dd33');

