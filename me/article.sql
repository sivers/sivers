create function me.article(_uri text, out body text) as $$
	select o.template('me-wrap', 'me-article', (select to_jsonb(r) from (
		select articles.title || ' | Derek Sivers' as pagetitle,
		articles.uri, articles.posted, articles.title,
		articles.original as body,
		metabooks.uri as in_book,
		coalesce(topics.uri, metabooks.uri) as topic_uri,
		coalesce(topics.name, metabooks.name) as topic_name,
		audios.filename as mp3,
		videos.filename as mp4
		from articles
		left join media as m1 on (articles.id = m1.article and m1.audio is not null)
		left join audios on m1.audio = audios.id
		left join media as m2 on (articles.id = m2.article and m2.video is not null)
		left join videos on m2.video = videos.id
		left join articles_topics on articles.id = articles_topics.article
		left join topics on articles_topics.topic = topics.uri
		left join chapters on articles.id = chapters.article_id
		left join metabooks on chapters.metabook_id = metabooks.id
		where articles.uri = $1
	) r));
$$ language sql;

