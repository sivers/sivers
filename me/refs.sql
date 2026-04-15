-- books that reference me
--
-- only for sive.rs/ref 

create function me.refs(out body text) as $$
	select o.template('me-wrap', 'me-refs', jsonb_build_object(
		'pagetitle', 'books that reference Derek Sivers',
		'howmany', (select count(*) from ebooks where refsme is not null),
		'books', (select jsonb_agg(r) from (
			select code as uri,
			(title || ' - by ' || author) as title,
			refsme
			from ebooks
			where refsme is not null
			order by length(refsme)
		) r)
	));
$$ language sql;

