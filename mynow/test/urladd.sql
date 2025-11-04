insert into people (id, name) values (1, 'Person A');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into urls (id, person_id, url, main) values (1, 1, 'https://a.com/', true);
insert into urls (id, person_id, url, main) values (2, 1, 'https://x.com/a', false);
alter table urls alter column id restart with 3;

select plan(17);

select is(head, e'303\r\nLocation: /f', 'nocookie'),
	is(body, null)
from mynow.urladd(null, 'a.nu');

select is(head, e'303\r\nLocation: /f', 'badcookie'),
	is(body, null)
from mynow.urladd('aaaXaaaXaaaXaaaXaaaXaaaaaaaaXaaa', 'a.nu');

select is(head, e'303\r\nLocation: /urls', 'added'),
	is(body, null)
from mynow.urladd('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', '  a . nu ');

select is(url, 'https://a.nu', 'url cleaned'),
	is(main, false, 'not main'),
	is(person_id, 1, 'right person')
from urls order by id desc limit 1;

select is(head, e'303\r\nLocation: /urls?err', 'improper url'),
	is(body, null)
from mynow.urladd('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', ' x ');

select is(head, e'303\r\nLocation: /urls?err', 'null url'),
	is(body, null)
from mynow.urladd('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', null);

select is(url, 'https://a.nu', 'bad url was not added')
from urls order by id desc limit 1;

select is(head, e'303\r\nLocation: /urls', 'added dupe'),
	is(body, null)
from mynow.urladd('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'https://a.com/');

select is(2, count(*)::integer, 'duplicates allowed (for now)')
from urls where url = 'https://a.com/';

