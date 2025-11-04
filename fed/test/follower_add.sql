select plan(6);

select is(count(*), 0::bigint) from followers;

select is(body ->> 'follower', 'https://z.io/users/alice'),
	is(body ->> 'response', 'added')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/123",
"type": "Follow",
"actor": "https://z.io/users/alice",
"object": "https://sive.rs/d"
}');

select is(body ->> 'response', 'added', 'dupe ok')
from fed.inbox('{"@context": "https://www.w3.org/ns/activitystreams",
"id": "https://z.io/activities/123",
"type": "Follow",
"actor": "https://z.io/users/alice",
"object": "https://sive.rs/d"
}');

select is(count(*), 1::bigint) from followers;

select is(actor, 'https://z.io/users/alice')
from followers limit 1;

