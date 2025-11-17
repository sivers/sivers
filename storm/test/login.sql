-- see tests in ~/omni/test/admin_auth.sql

insert into people (id, name) values (1, 'admin1');
insert into people (id, name) values (2, 'admin2');
insert into people (id, name) values (3, 'admin3');

insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (2, 'two@two.two');
insert into ats (person_id, email) values (3, 'tri@tri.tri');

insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into admins (person_id) values (1);
insert into admins (person_id) values (2);
insert into admins (person_id) values (3);

insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into admin_auths (person_id, appcode) values (2, 'storm');
insert into admin_auths (person_id, appcode) values (3, 'other');

select o.admin_pass_set(1, 'one?password!');
select o.admin_pass_set(2, 'two!password?');
select o.admin_pass_set(3, 'tri!password!');

select plan(10);

select is(body, null, 'wrong password'),
	is(head, e'303\r\nLocation: /login')
from storm.login('one@one.one', 'wrong?password!');

select is(body, null, 'not storm app'),
	is(head, e'303\r\nLocation: /login')
from storm.login('tri@tri.tri', 'tri!password!');

select is(body, null, 're-uses cookie'),
	is(head, e'303\r\nSet-Cookie: ok=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /')
from storm.login('one@one.one', 'one?password!');

select is(body, null, 'new cookie'),
	ok(strpos(head, 'Set-Cookie') > 0),
	isnt(head, e'303\r\nSet-Cookie: ok=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /')
from storm.login('two@two.two', 'two!password?');

select is(count(cookie), 2::bigint) from logins;

