insert into people (id, name) values (1, 'Person A');
insert into people (id, name) values (2, 'Person B');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into urls (id, person_id, url, main) values (1, 1, 'https://a.com/', true);
insert into urls (id, person_id, url, main) values (2, 1, 'https://x.com/a', false);
insert into urls (id, person_id, url, main) values (3, 2, 'https://not-their-url.com', false);

select plan(10);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.urldel(null, 1);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.urldel('dddXdddXdddXdddXdddXdddXdddXdddd', 1);

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'not theirs... ')
from mynow.urldel('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 3);

select is(id, 3, '... so was not deleted') from urls where id = 3;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'delete... ')
from mynow.urldel('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 2);

select is(count(*)::integer, 1, '... was deleted') from urls where person_id = 1;

