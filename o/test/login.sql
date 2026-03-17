insert into people (id, name) values (1, 'A');
insert into people (id, name) values (2, 'B');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(7);

select is(cookie, 'abcdefghijklmnopqrstuvwxyz012345') from o.login(1);

select is(1, count(*)::integer) from logins;

select is(32, length(cookie)), isnt(cookie, 'abcdefghijklmnopqrstuvwxyz012345') from o.login(2);

select is(2, count(*)::integer) from logins;

-- run a query without returning it to the screen
select lives_ok('select * from o.login(2)');

select is(2, count(*)::integer, 'did not add another') from logins;

