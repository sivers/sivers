-- just test inbox routing here.  test actual activities in those functions.

select plan(13);

select is(body ->> 'error', 'wrongtype'),
	is(body ->> 'type', null)
from fed.inbox('{}');

select is(body ->> 'error', 'wrongtype'),
	is(body ->> 'type', 'blah')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams", "id": "https://z.io/activities/123", "type": "blah"}');

select is(body ->> 'follower', 'https://z.io/users/alice'),
	is(body ->> 'response', 'added')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/123",
"type": "Follow",
"actor": "https://z.io/users/alice",
"object": "https://sive.rs/d"
}');

select is(body ->> 'follower', 'https://z.io/users/alice'),
	is(body ->> 'response', 'deleted')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/124",
"type": "Undo",
"actor": "https://z.io/users/alice",
"object": {
	"type": "Follow",
	"actor": "https://z.io/users/alice",
	"object": "https://sive.rs/d"
}}');

select is(body ->> 'actor', 'https://z.io/users/alice'),
	is(body ->> 'response', 'mention'),
	is(body ->> 'id', 'https://z.io/posts/999'),
	is(body ->> 'content', 'Yo!'),
	is(body ->> 'response2', null)
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/125",
"type": "Create",
"actor": "https://z.io/users/alice",
"to": ["https://sive.rs/d"],
"object": {
	"id": "https://z.io/posts/999",
	"type": "Note",
	"attributedTo": "https://z.io/users/alice",
	"content": "Yo!",
	"to": ["https://sive.rs/d"]
}}');

