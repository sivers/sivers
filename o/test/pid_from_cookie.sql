insert into people (id, name) values (1, 'A');
insert into logins (person_id, cookie) values (1, 'abcdefghijklmnop');

select plan(2);

select is(o.pid_from_cookie('abcdefghijklmnop'), 1);
select is(o.pid_from_cookie('xxx'), null);

