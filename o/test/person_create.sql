insert into people (id, name) values (1, 'Person A');
select setval('people_id_seq', 1);
insert into ats (email, person_id, used) values ('a@a.com', 1, '2000-01-01 01:01:01');

select plan(6);

select is(o.person_create('A Person', '  A@A.COM '), 1);
select ok(used > '2025-08-08 08:08:08') from ats where email = 'a@a.com';

select is(o.person_create(e' \n New  \t Person \r', ' NU@nu.nu '), 2);
select is(name, 'New Person'),
	is(greeting, 'New')
	from people where id = 2;
select is(email, 'nu@nu.nu') from ats where person_id = 2 limit 1;

