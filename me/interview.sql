create function me.interview(_uri text, out body text) as $$
begin
	body = o.template('me-wrap', 'me-interview', (select to_jsonb(r) from (
		select 
		(case when name = host then name else name || ' by '|| host end) || ' | Derek Sivers' as pagetitle,
		interviews.id, interviews.uri, ymdhm::date as ymd,
		(case when name = host then name else name || ' by '|| host end) as title,
		their_url, summary,
		audios.filename as mp3,
		videos.filename as mp4, (select json_agg(r) from (
			select (case when speaker = 'sivers' then 'Derek Sivers' else speaker end) as speaker,
			content
			from utterances
			where interview_id = interviews.id
			order by seconds
		) r) as segments
		from interviews
		left join media as m1 on (interviews.id = m1.interview and m1.audio is not null)
		left join audios on m1.audio = audios.id
		left join media as m2 on (interviews.id = m2.interview and m2.video is not null)
		left join videos on m2.video = videos.id
		where interviews.uri = $1
	) r));
end;
$$ language plpgsql;

