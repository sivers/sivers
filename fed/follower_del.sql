-- /inbox "type": "Undo"
create function fed.follower_del(jsonb,
	out head text, out body json) as $$
declare
	actor1 text;
begin
	actor1 = $1 ->> 'actor';

	delete from followers where actor = actor1;

	body = json_build_object('response', 'deleted', 'follower', actor1);
end;
$$ language plpgsql;

