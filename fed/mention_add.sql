-- /inbox "type": "Create"
create function fed.mention_add(jsonb,
	out head text, out body json) as $$
declare
	actor text;
	their_id text;
	content text;
	response2 integer; -- tweets.id
begin
	actor = $1 ->> 'actor';
	their_id = $1 -> 'object' ->> 'id';
	content = $1 -> 'object' ->> 'content';

	-- says it's inReplyTo one of my tweets? find refs_id or null
	if ($1 -> 'object' ->> 'inReplyTo') is not null then
		select tweets.id into response2
		from tweets
		where apub = $1 -> 'object' ->> 'inReplyTo';
	end if;

	insert into mentions (refs_id, userid, message, apub)
	values (response2, actor, content, their_id)
	on conflict (apub) do nothing;

	body = json_build_object('response', 'mention', 'actor', actor, 'id', their_id, 'response2', response2, 'content', content);
end;
$$ language plpgsql;

