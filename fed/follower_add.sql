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

	body = json_build_object('response', 'added', 'follower', actor1);
end;
$$ language plpgsql;

