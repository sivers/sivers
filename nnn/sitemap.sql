create function nnn.sitemap(out body text) as $$
begin
	body = o.template('nnn-sitemap', jsonb_build_object(
		'ymd', (select current_date),
		'places', (select jsonb_agg(r) from (
			select url from nnn.places()
		) r),
		'profiles', (select jsonb_agg(r) from (
			select uri from nnn.profiles()
		) r)
	));
end;
$$ language plpgsql;
