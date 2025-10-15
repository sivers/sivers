insert into people (id, name) values (1, 'a');
insert into people (id, name) values (3, 'checker1');

insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (1, 1, '2025-02-02', '2025-03-03', now(), 3, '2025-04-04', 1, false, 'a.com', 'https://a.com/', 'last updated March 3, 2025');

-- note function has same auth code as nowx-one.sql so not repeating those auth tests here

select plan(20);

select is(body, null), is(head, e'303\r\nLocation: /check/1')
from nowx.update('cccccccccccccccccccccccccccccccc', 1,
	'{"long":"", "look4":" last updated March 3, 2025 ", "updated_at":""}'::jsonb);

select is(long, 'https://a.com/'),
	is(updated_at, '2025-03-03'),
	is(look4, 'last updated March 3, 2025')
from now_pages where id = 1;

select is(body, null), is(head, e'303\r\nLocation: /check/1')
from nowx.update('cccccccccccccccccccccccccccccccc', 1,
	'{"long":"  https://aaa.com/ "}'::jsonb);

select is(long, 'https://aaa.com/'),
	is(updated_at, '2025-03-03'),
	is(look4, 'last updated March 3, 2025')
from now_pages where id = 1;

select is(body, null), is(head, e'303\r\nLocation: /check/1')
from nowx.update('cccccccccccccccccccccccccccccccc', 1,
	'{"oops":"nevermind", "updated_at":"WTF-TRASH-IS-THIS", "look4":"☺", "long":"https://aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.disco/what-am-i-doing-now-you-ask-well-let-me-tell-you"}'::jsonb);

select is(long, 'https://aaa.com/'),
	is(updated_at, '2025-03-03'),
	is(look4, 'last updated March 3, 2025')
from now_pages where id = 1;

select is(body, null), is(head, e'303\r\nLocation: /check/1')
from nowx.update('cccccccccccccccccccccccccccccccc', 1,
	'{"updated_at":"2025-10-15", "look4":" October 15 "}'::jsonb);

select is(long, 'https://aaa.com/'),
	is(updated_at, '2025-10-15'),
	is(look4, 'October 15')
from now_pages where id = 1;

