insert into followers (actor) values ('https://z.io/users/alice');
insert into followers (actor) values ('https://z.io/users/bob');

select plan(3);

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

select is(count(*), 1::bigint)
from followers;

