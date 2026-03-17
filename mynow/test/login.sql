insert into people (id, name) values (1, 'Person A');
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

select plan(8);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'wrong tempcode')
from mynow.login('XXXdefghijklXXXX', 1);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'right tempcode wrong person_id')
from mynow.login('abcdefghijklmnop', 2);

select is(head, e'303\r\nSet-Cookie: ok=abcdefghijklmnopqrstuvwxyz012345; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /'),
	is(body, null)
from mynow.login('abcdefghijklmnop', 1);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'only works once')
from mynow.login('abcdefghijklmnop', 1);

