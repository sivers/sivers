insert into countries (code, name) values ('GB', 'Great Britain');
insert into templates (code, template) values ('me-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('me-commentpost', 'uri={{uri}},name={{name}}');

insert into articles (uri, posted, title, original) values ('apost', '2026-04-01', 'A Post', '<p>This is a post.</p>');

insert into people (id, name) values (1, 'Past Poster');
insert into ats (person_id, email) values (1, 'past@poster.com');
insert into comments (id, person_id, uri, name, email, comment) values (1, 1, 'apost', 'Past Poster', 'past@poster.com', 'Past comment.');

insert into ips (range, country, state, city) values ('[16843008,16843264)', 'GB', 'ENG', 'Oxford'); -- 1.1.1.1

select setval('people_id_seq', 1);
select setval('comments_id_seq', 1);

select plan(16);
select is(count(*)::integer, 1, 'one comment') from comments;

select is(head, null, 'empty head'),
	is(body, '<html>uri=apost,name=Willy Wonka</html>', 'basic body')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'name', '  Willy Wonka',
	'email', 'WILLY@WONKA.COM',
	'comment', 'Chocolate is good.',
	'ip', '1.1.1.1'));

select is(count(*)::integer, 2, 'new comment') from comments;

select is(name, 'Willy Wonka', 'name'),
	is(ats.email, 'willy@wonka.com', 'ats.email')
from people join ats on people.id = ats.person_id where people.id = 2;

select is(statvalue, 'Oxford', 'ip saved location')
from stats where person_id = 2 and statkey = 'city';

select is(uri, 'apost'),
	is(name, 'Willy Wonka'),
	is(email, 'willy@wonka.com'),
	is(comment, 'Chocolate is good.')
from comments where id = 2;

-- Now let's do some bad ones:
select is(head, e'303\r\nLocation: /thanks', 'wrong uri')
from me.comment_post(jsonb_build_object(
	'uri', 'xx',
	'name', 'Willy Wonka',
	'email', 'willy@wonka.com',
	'comment', 'Chocolate is good.'));

select is(head, e'303\r\nLocation: /thanks', 'crypto name')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'name', 'Hot Crypto Now',
	'email', 'willy@wonka.com',
	'comment', 'Chocolate is good.'));

select is(head, e'303\r\nLocation: /thanks', 'test name')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'name', 'test',
	'email', 'willy@wonka.com',
	'comment', 'Chocolate is good.'));

select is(head, e'303\r\nLocation: /thanks', 'test@ email')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'name', 'Willy Wonka',
	'email', 'test@wonka.com',
	'comment', 'Chocolate is good.'));

select is(head, e'303\r\nLocation: /thanks', '@example email')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'name', 'Willy Wonka',
	'email', 'willy@example.com',
	'comment', 'Chocolate is good.'));

