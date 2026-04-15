create function me.presentation(_uri text, out body text) as $$
	select o.template('me-wrap', 'me-presentation', (select to_jsonb(r) from (
		select (title || ' by Derek Sivers') as pagetitle,
		uri, title, description, month, minutes, transcript,
		(select json_agg(r) from (
			select audios.filename
			from media
			join audios on media.audio = audios.id
			where presentation = $1
			order by media.sortid
		) r) as mp3s,
		(select json_agg(r) from (
			select videos.filename
			from media
			join videos on media.video = videos.id
			where presentation = $1
			order by media.sortid
		) r) as mp4s
		from presentations
		where uri = $1
	) r));
$$ language sql;

