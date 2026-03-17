-- nownownow.com/about
create function nnn.about(out body text) as $$
begin
	body = o.template('nnn-wrap', 'nnn-about',
		jsonb_build_object('pagetitle',
			'about nownownow.com'));
end;
$$ language plpgsql;
