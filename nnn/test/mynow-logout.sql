insert into people (id, name) values (1, 'Person A');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(4);

select is(1, count(*)::integer) from logins where person_id = 1;

select is(head, e'303\r\nSet-Cookie: ok=; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=0\r\nLocation: /f'),
	is(body, null)
from mynow.logout('abcdefghijklmnopqrstuvwxyz012345');

select is(0, count(*)::integer) from logins where person_id = 1;

