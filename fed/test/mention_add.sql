insert into tweets (id, message, apub) values (1, 'hello!', 'https://sive.rs/d/posts/1');

select plan(12);

select is(count(*), 0::bigint) from mentions;

select is(body ->> 'actor', 'https://z.io/users/alice'),
	is(body ->> 'response', 'mention'),
	is(body ->> 'id', 'https://z.io/posts/999'),
	is(body ->> 'content', 'Yo!'),
	is(body ->> 'response2', '1', 'found tweets.id 1')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/125",
"type": "Create",
"actor": "https://z.io/users/alice",
"to": ["https://sive.rs/d"],
"object": {
	"id": "https://z.io/posts/999",
	"type": "Note",
	"attributedTo": "https://z.io/users/alice",
	"inReplyTo": "https://sive.rs/d/posts/1",
	"content": "Yo!",
	"to": ["https://sive.rs/d"]
}}');

select is(body ->> 'response2', '1', 'dupe ok')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/125",
"type": "Create",
"actor": "https://z.io/users/alice",
"to": ["https://sive.rs/d"],
"object": {
	"id": "https://z.io/posts/999",
	"type": "Note",
	"attributedTo": "https://z.io/users/alice",
	"inReplyTo": "https://sive.rs/d/posts/1",
	"content": "Yo!",
	"to": ["https://sive.rs/d"]
}}');

select is(count(*), 1::bigint) from mentions;

select is(refs_id, 1),
	is(userid, 'https://z.io/users/alice'),
	is(message, 'Yo!'),
	is(apub, 'https://z.io/posts/999')
from mentions order by id desc limit 1;


