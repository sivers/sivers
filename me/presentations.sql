create function me.presentations(out body text) as $$
begin
	body = o.template('me-wrap', 'me-presentations', jsonb_build_object(
		'pagetitle', 'Derek Sivers TED talks, conference presentations',
		'howmany', (select count(*) from me.presentation_uris()),
		'presentations', (select jsonb_agg(r) from (
			select uri, title, description, month, minutes
			from presentations
			where uri in (select me.presentation_uris())
			order by month desc
		) r)
	));
end;
$$ language plpgsql;

