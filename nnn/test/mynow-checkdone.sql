insert into people (id, name) values (0, 'robot');
insert into people (id, name, greeting) values (1, 'A', 'darling A');
insert into people (id, name) values (3, 'checker1');
insert into ats (person_id, email) values (1, 'a@a.com');

insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (1, 1, '2025-02-02', '2025-03-03', now(), 3, '2025-04-04', 1, false, 'a.com', 'https://a.com/', 'last updated March 3, 2025');
insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (2, 3, '2025-02-03', '2025-03-04', null, null, '2025-04-04', 1, false, 'b.com', 'https://b.com/', 'should turn up next');

-- hard-coded ids, yeah
insert into formletters (id, title, subject, body) values (21, 'now-check-nodate', '{short} has no date', 'your /now page has no date: {long}');
insert into formletters (id, title, subject, body) values (22, 'now-check-old', '{short} is old', 'your /now page is old: {long}');
insert into formletters (id, title, subject, body) values (23, 'now-check-good', '{short} is good', 'your /now page is good: {long}');
insert into formletters (id, title, subject, body) values (24, 'now-check-gone', '{short} is gone?', 'your /now page is gone? {long}');
insert into configs (k, v) values ('sig', 'signing off');  -- necessary


-- note function has same auth code as nowx-one.sql so not repeating those auth tests here

select plan(20);

select is(body, null), is(head, e'303\r\nLocation: /check/1')
from nowx.done('cccccccccccccccccccccccccccccccc', 1, 'wrong-action');

select is(updated_at, '2025-03-03'),
	isnt(review_at, null),
	is(review_by, 3),
	is(checked_at, '2025-04-04'),
	is(checked_by, 1),
	is(flagged, false)
from now_pages where id = 1;

select is(body, null), is(head, e'303\r\nLocation: /check/2', 'on to the next')
from nowx.done('cccccccccccccccccccccccccccccccc', 1, 'gone');

select is(updated_at, '2025-03-03'),
	is(review_at, null),
	is(review_by, null),
	is(checked_at, current_date),
	is(checked_by, 3),
	is(flagged, true)
from now_pages where id = 1;

select isnt(review_at, null, 'next claimed at'),
is(review_by, 3, 'next claimed by')
from now_pages where id = 2;

select is(subject, 'a.com is gone?', 'form subject'),
	is(body, e'Hi darling A -\n\nyour /now page is gone? https://a.com/\n\n--\nsigning off', 'form body')
from emails order by id desc limit 1;

