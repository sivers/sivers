insert into people (id, name) values (1, 'a');
insert into people (id, name) values (3, 'checker1');

insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (1, 1, '2025-02-02', '2025-03-21', now(), 3, '2025-04-04', 1, false, 'a.com', 'https://a.com/', 'last updated March 21, 2025');
insert into now_pages (id, person_id, created_at, updated_at, review_at, review_by, checked_at, checked_by, flagged, short, long, look4)
values (2, 3, '2025-02-03', '2025-03-04', null, null, '2025-04-04', 1, false, 'b.com', 'https://b.com/', 'last updated March 4, 2025');

insert into templates (code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-check', 'vars needed by checker:
id={{id}}
updated_at={{updated_at}}
updated_at2={{updated_at2}}
today={{today}}
long={{long}}
look4={{look4}}
');

select plan(15);

select is(body, null),
	is(head, e'303\r\nLocation: /check', 'login')
from mynow.checkone(null, 1);

select is(body, null),
	is(head, e'303\r\nLocation: /check', 'only seen by one who claimed it to review')
from mynow.checkone('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

select is(body, null),
	is(head, e'303\r\nLocation: /check', 'yes checker but wrong now_page')
from mynow.checkone('cccccccccccccccccccccccccccccccc', 2);

select is(body, null),
	is(head, e'303\r\nLocation: /check', 'yes checker but non-existent now_page')
from mynow.checkone('cccccccccccccccccccccccccccccccc', 3);

select is(head, null),
	ok(strpos(body, 'id=1') > 0, 'id'),
	ok(strpos(body, 'updated_at=2025-03-21') > 0, 'updated_at'),
	ok(strpos(body, 'updated_at2=21 March 2025') > 0, 'updated_at2'),
	ok(strpos(body, 'today=202') > 0, 'today, probably'),
	ok(strpos(body, 'long=https://a.com/') > 0, 'long'),
	ok(strpos(body, 'look4=last updated March 21') > 0, 'look4')
from mynow.checkone('cccccccccccccccccccccccccccccccc', 1);

