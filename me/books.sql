create function me.books(out body text) as $$
begin
	body = o.template('me-wrap', 'me-books', jsonb_build_object(
		'pagetitle', 'book notes by Derek Sivers',
		'books', (select jsonb_agg(r) from (
			select code as uri, read as ymd,
			(title || ' - by ' || author) as title,
			rating, summary
			from ebooks
			where code in (select me.book_uris())
			order by read desc nulls last
		) r)
	));
end;
$$ language plpgsql;

