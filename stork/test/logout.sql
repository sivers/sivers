insert into people (id, name) values (0, 'Ad Min');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 0);
insert into admins (person_id) values (0);
insert into admin_auths (person_id, appcode) values (0, 'stork');

select plan(4);

select is(1, count(*)::integer) from logins where person_id = 0;

select is(head, e'303\r\nSet-Cookie: ok=; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=0\r\nLocation: /login'),
	is(body, null)
from stork.logout('abcdefghijklmnopqrstuvwxyz012345');

select is(0, count(*)::integer) from logins where person_id = 0;

