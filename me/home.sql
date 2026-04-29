create function me.home(out body text) as $$
	select o.template('me-wrap', 'me-home', jsonb_build_object(
		'pagetitle', 'Derek Sivers',
		'topics', me.topics()
	));
$$ language sql;

