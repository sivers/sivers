-- just list id, name of videos that have seconds but no youtube
-- assumes that means the videos are created but not finished
-- HTML just lists and links to /vt/{{id}}
create function peep.videotext_list(
	out head text, out body text) as $$
declare
	vids jsonb;
begin
	vids = coalesce((select json_agg(r) from (
		select id, name
		from videos
		where seconds is not null
		and seconds > 0
		and (youtube is null or youtube = '')
		order by id asc
	) r), '[]');

	body = o.template('peep-wrap', 'peep-video-list', jsonb_build_object(
		'videos', vids
	));
end;
$$ language plpgsql;

