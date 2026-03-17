insert into people (id, name) values (0, 'bot');
insert into people (id, name) values (1, 'a');
insert into people (id, name) values (2, 'b');
insert into people (id, name) values (3, 'checker1');

-- necessary for formletter
insert into configs (k, v) values ('sig', 'signing off');
insert into ats (email, person_id) values ('ro@b.ot', 0);
insert into ats (email, person_id) values ('a@a.com', 1);
insert into ats (email, person_id) values ('b@b.com', 2);

insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (1, 1, '2025-02-02', '2019-08-08', now(), 3, '2025-04-04', 1, false, 'a.com', 'https://a.com/', 'last updated March 3, 2025');
insert into now_pages (id, person_id, created_at, updated_at, checked_at, checked_by, flagged, short, long, look4)
values (2, 2, '2025-02-02', '2025-08-08', '2025-04-04', 1, false, 'b.com', 'https://b.com/', 'b is updated');
insert into now_pages (id, person_id, checked_at, long) values (3, 3, '2025-10-01', 'https://checker1.com/');

insert into formletters (id, title, subject, body) values (22, 'now-check-old', '{short} is old', 'your /now page is old: {long}');
insert into formletters (id, title, subject, body) values (23, 'now-check-good', '{short} is good', 'your /now page is good: {long}');

-- note same auth code as mynow-checkone.sql so not repeating those auth tests here

select plan(29);

select is(body, null, 'look4 is too short but date is OK'),
	is(head, e'303\r\nLocation: /check/1')
from mynow.checkupdate('cccccccccccccccccccccccccccccccc', 1, '25', '2020-07-31'::date);

select is(look4, 'last updated March 3, 2025', 'look4 unchanged'),
	is(updated_at, '2020-07-31'::date, 'date changed'),
	is(review_by, 3, 'still under review'),
	is(checked_at, '2025-04-04'::date, 'checked_at unchanged')
from now_pages where id = 1;

select is(body, null, 'look4 too long but date is OK'),
	is(head, e'303\r\nLocation: /check/1')
from mynow.checkupdate('cccccccccccccccccccccccccccccccc', 1, 'xxxxxxxxxxxxxxTOO-LONGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', '2021-08-30'::date);

select is(look4, 'last updated March 3, 2025', 'look4 unchanged'),
	is(updated_at, '2021-08-30'::date, 'date changed'),
	is(review_by, 3, 'still under review'),
	is(checked_at, '2025-04-04'::date, 'checked_at unchanged')
from now_pages where id = 1;

select is(body, null, 'look4 is good but date is in the past'),
	is(head, e'303\r\nLocation: /check/2')
from mynow.checkupdate('cccccccccccccccccccccccccccccccc', 1, 'updated right now', '1999-01-01'::date);

select is(look4, 'updated right now', 'look4 changed'),
	is(updated_at, '2021-08-30'::date, 'date unchanged'),
	is(review_by, null, 'NOT under review'),
	is(checked_by, 3, 'checked_by changed')
from now_pages where id = 1;

select is(count(*), 1::bigint, 'one email') from emails;

select is(subject, 'a.com is old', 'old date = old site formletter')
from emails order by id desc limit 1;

select is(review_by, 3, 'now reviewing next!')
from now_pages where id = 2;

select is(body, null, 'look4 is good and date is today'),
	is(head, e'303\r\nLocation: /check/3')
from mynow.checkupdate('cccccccccccccccccccccccccccccccc', 2, 'right now', current_date);

select is(look4, 'right now', 'look4 changed'),
	is(updated_at, current_date, 'date changed'),
	is(review_by, null, 'NOT under review'),
	is(checked_by, 3, 'checked_by changed')
from now_pages where id = 2;

select is(count(*), 2::bigint, 'two emails') from emails;

select is(subject, 'b.com is good', 'new date = good site formletter')
from emails order by id desc limit 1;

