insert into people (id, name) values (1, 'EE');
insert into people (id, name) values (2, 'DD');
insert into people (id, name) values (3, 'CC');

insert into now_pages (person_id, long) values (1, 'https://ee.com/');
insert into now_pages (person_id, long) values (2, 'https://dd.com/');
insert into now_pages (person_id, long) values (3, 'https://cc.com/');

select plan(2);

select is(body, null),
	matches(head, e'303\r\nLocation: https://..\.com/')
from nnn.random();

