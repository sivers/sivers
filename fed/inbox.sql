-- route incoming inbox posts to the right function
create function fed.inbox(jsonb,
	out head text, out body json) as $$
declare
begin
	case $1 ->> 'type'
	when 'Follow' then
		select x.head, x.body into head, body from fed.follower_add($1) x;
	when 'Undo' then
		select x.head, x.body into head, body from fed.follower_del($1) x;
	when 'Create' then
		select x.head, x.body into head, body from fed.mention_add($1) x;
	else
		body = json_build_object('error', 'wrongtype', 'type', $1 ->> 'type');
	end case;
end;
$$ language plpgsql;

