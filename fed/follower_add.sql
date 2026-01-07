-- /inbox "type": "Follow"
create function fed.follower_add(jsonb,
	out head text, out body json) as $$
declare
	actor1 text;
begin
	actor1 = $1 ->> 'actor';

	insert into followers (actor)
	values (actor1)
	on conflict (actor) do nothing;

	head = e'202\r\nContent-Type: application/activity+json';
end;
$$ language plpgsql;

