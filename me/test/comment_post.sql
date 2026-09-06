insert into countries (code, name) values ('GB', 'Great Britain');
insert into templates (code, template) values ('me-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('me-commentpost', 'OK uri={{uri}},name={{name}}');
insert into templates (code, template) values ('me-commentno', 'NO uri={{uri}},email={{email}},comment={{{comment}}}');

insert into topics (uri) values ('test');
insert into articles (topic, uri, posted, title, original) values ('test', 'apost', '2026-04-01', 'A Post', '<p>This is a post.</p>');

insert into people (id, name, greeting) values (1, 'Past Poster', 'Posterman');
insert into ats (person_id, email, used) values (1, 'past@poster.com', '2026-04-01');
insert into comments (id, person_id, uri, name, email, comment) values (1, 1, 'apost', 'Past Poster', 'past@poster.com', 'Past comment.');

insert into ips (range, country, state, city) values ('[16843008,16843264)', 'GB', 'ENG', 'Oxford'); -- 1.1.1.1

select setval('people_id_seq', 1);
select setval('comments_id_seq', 1);

select plan(14);
select is(count(*)::integer, 1, 'one comment') from comments;

---- A GOOD POST:

select is(head, null, 'empty head'),
	is(body, '<html>OK uri=apost,name=Posterman</html>', 'posted ok')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'email', ' PAST @ POSTER . COM ',
	'comment', 'A <strong>new</strong> comment.',
	'ip', '1.1.1.1'));

select is(count(*)::integer, 2, 'new comment') from comments;
select is(uri, 'apost', 'uri match'),
	is(person_id, 1, 'person_id match'),
	is(name, 'Posterman', 'got name from db'),
	is(comment, 'A new comment.', 'cleaned comment')
from comments order by id desc limit 1;

select is(statvalue, 'Oxford', 'ip saved location')
from stats where person_id = 2 and statkey = 'city';

select isnt(used, '2026-04-01', 'ats.used updated')
from ats where email = 'past@poster.com';

-- BAD POSTS:

select is(head, e'303\r\nLocation: /thanks', 'wrong uri')
from me.comment_post(jsonb_build_object(
	'uri', 'xx',
	'email', 'willy@wonka.com',
	'comment', 'Chocolate is good.'));

select is(head, null, 'empty head'),
	is(body, '<html>NO uri=apost,email=willy@wonka.com,comment=A new comment.</html>', 'cleaned,refused')
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'email', ' willy@WONKA.com ',
	'comment', 'A <strong>new</strong> comment.'));

select is(head, e'303\r\nLocation: /apost', 'dupe sends back'),
	is(body, null)
from me.comment_post(jsonb_build_object(
	'uri', 'apost',
	'email', 'past@poster.com',
	'comment', 'Past comment.'));
