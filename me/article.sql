create or replace function me.article(_uri text, out body text) as $$
	select o.template('me-wrap', 'me-article', (select to_jsonb(r) from (
		select articles.title || ' | Derek Sivers' as pagetitle,
		articles.uri, articles.posted, articles.title,
		audios.filename as mp3,
		videos.filename as mp4,
		metabooks.uri as book_uri,
		metabooks.name as book_name,
		atags.tag,
		articles.original as body
		from articles
		left join media as m1 on (articles.id = m1.article and m1.audio is not null)
		left join audios on m1.audio = audios.id
		left join media as m2 on (articles.id = m2.article and m2.video is not null)
		left join videos on m2.video = videos.id
		left join chapters on articles.id = chapters.article_id
		left join metabooks on chapters.metabook_id  = metabooks.id
		left join atags on articles.id = atags.article_id
		where articles.uri = $1
	) r));
$$ language sql;
