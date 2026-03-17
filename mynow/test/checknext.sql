insert into people (id, name) values (1, 'a');
insert into people (id, name) values (2, 'b');
insert into people (id, name) values (3, 'checker1');
insert into people (id, name) values (4, 'checker2');
insert into people (id, name) values (5, 'stranger');

insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);
insert into logins (cookie, person_id) values ('dddddddddddddddddddddddddddddddd', 4);
insert into logins (cookie, person_id) values ('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 5);

insert into now_pages (id, person_id, checked_at, long) values (1, 1, '2025-02-02', 'https://a.com/');
insert into now_pages (id, person_id, checked_at, long) values (2, 2, '2025-01-01', 'https://b.com/');
insert into now_pages (id, person_id, checked_at, long) values (3, 3, '2025-10-01', 'https://checker1.com/');
insert into now_pages (id, person_id, checked_at, long) values (4, 4, '2025-10-02', 'https://checker2.com/');

select plan(18);

select is(body, null),
	is(head, e'303\r\nLocation: /f', 'login')
from mynow.checknext(null);

select is(body, null),
	is(head, e'303\r\nLocation: /f', 'only people with now_pages can check')
from mynow.checknext('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

select is(body, null),
	is(head, e'303\r\nLocation: /check/2', 'first checker gets next avail')
from mynow.checknext('cccccccccccccccccccccccccccccccc');

select is(body, null),
	is(head, e'303\r\nLocation: /check/1', 'simultaneous checker gets other')
from mynow.checknext('dddddddddddddddddddddddddddddddd');

select is(body, null),
	is(head, e'303\r\nLocation: /check/2', 're-get gets their open one: 2')
from mynow.checknext('cccccccccccccccccccccccccccccccc');

select is(body, null),
	is(head, e'303\r\nLocation: /check/1', 're-get gets their open one: 1')
from mynow.checknext('dddddddddddddddddddddddddddddddd');

select is(review_by, 3), isnt(review_at, null) from now_pages where id = 2;
select is(review_by, 4), isnt(review_at, null) from now_pages where id = 1;
select is(review_by, null), is(review_at, null) from now_pages where id = 3;
