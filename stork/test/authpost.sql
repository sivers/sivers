insert into people (id, name) values (1, 'Ad Min');
insert into ats (person_id, email) values (1, 'ad@m.in');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);
insert into admins (person_id, hashpass) values (1, crypt('Pass,Word?', gen_salt('bf', 10)));
insert into admin_auths (person_id, appcode) values (1, 'storm');

select plan(6);

select is(head, e'303\r\nLocation: /login'),
	is(body, null, 'wrong password')
from storm.authpost('ad@m.in', 'PassWeird');

select is(head, e'303\r\nSet-Cookie: ok=abcdefghijklmnopqrstuvwxyz012345; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /'),
	is(body, null)
from storm.authpost('ad@m.in', 'Pass,Word?');

select is(head, e'303\r\nSet-Cookie: ok=abcdefghijklmnopqrstuvwxyz012345; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /'),
	is(body, null, 'post again, same result')
from storm.authpost('ad@m.in', 'Pass,Word?');

