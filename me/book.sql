create function me.book(_uri text, out body text) as $$
	select o.template('me-wrap', 'me-book', (select to_jsonb(r) from (
		select (title || ' - by ' || author || ' | Derek Sivers') as pagetitle,
		code, title, author, isbn, read, rating, summary, (
			select string_agg(e'\n<p>'
				|| o.escape_html(ebooknotes.note)
				|| '</p>', '' order by ebooknotes.sortid)
			from ebooknotes
			where ebook_code = $1
		) as notes
		from ebooks
		where code = $1
	) r));
$$ language sql;

