create function me.article(_uri text, out body text) as $$
	select o.template('me-wrap', 'me-article', (select to_jsonb(r) from (
		select articles.title || ' | Derek Sivers' as pagetitle,
		articles.uri, articles.posted, articles.title,
		articles.original as body,
		topic,
		topics.name as topic_name,
		metabooks.uri as in_book,
		audios.filename as mp3,
		videos.filename as mp4
		from articles
		join topics on articles.topic = topics.uri
		left join chapters on articles.id = chapters.article_id
		left join metabooks on chapters.metabook_id = metabooks.id
		left join media as m1 on (articles.id = m1.article and m1.audio is not null)
		left join audios on m1.audio = audios.id
		left join media as m2 on (articles.id = m2.article and m2.video is not null)
		left join videos on m2.video = videos.id
		where articles.uri = $1
	) r));
$$ language sql;

