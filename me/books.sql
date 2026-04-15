create function me.books(out body text) as $$
	select o.template('me-wrap', 'me-books', jsonb_build_object(
		'pagetitle', 'book notes by Derek Sivers',
		'howmany', (select count(*) from me.book_uris()),
		'books', (select jsonb_agg(r) from (
			select code as uri, read,
			(title || ' - by ' || author) as title,
			rating, summary
			from ebooks
			where code in (select me.book_uris())
			order by rating desc, read desc
		) r)
	));
$$ language sql;

