insert into people (id, name) values (1, 'Person A');
insert into people (id, name) values (2, 'Person B');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into urls (id, person_id, url, main) values (1, 1, 'https://a.com/', true);
insert into urls (id, person_id, url, main) values (2, 1, 'https://x.com/a', false);
insert into urls (id, person_id, url, main) values (3, 2, 'https://not-their-url.com', false);
insert into urls (id, person_id, url, main) values (4, 1, 'https://aaa.net/', false);

select plan(12);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.urlmain(null, 1);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.urlmain('dddXdddXdddXdddXdddXdddXdddXdddd', 1);

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'not theirs, so... ')
from mynow.urlmain('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 3);

select is(main, false, '... not altered') from urls where id = 3;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'theirs so... ')
from mynow.urlmain('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 2);

select is(main, true, 'now main') from urls where id = 2;
select is(main, false, 'others not') from urls where id = 1;
select is(main, false, 'others not') from urls where id = 4;

