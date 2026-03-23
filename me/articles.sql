create function me.articles(out body text) as $$
begin
	body = o.template('me-wrap', 'me-articles', jsonb_build_object(
		'pagetitle', 'Derek Sivers articles',
		'howmany', (select count(*) from me.article_uris()),
		'articles', (select jsonb_agg(r) from (
			select uri, posted as ymd, title
			from articles
			where uri in (select me.article_uris())
			order by posted desc nulls last, id desc
		) r)
	));
end;
$$ language plpgsql;

