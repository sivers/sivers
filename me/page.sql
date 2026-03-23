-- for any static page in templates under /templates/me-{uri}.html

create function me.page(_uri text, _pagetitle text, out body text) as $$
begin
	body = o.template('me-wrap', 'me-' || $1,
		jsonb_build_object('pagetitle', $2)
	);
end;
$$ language plpgsql;

