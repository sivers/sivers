-- nownownow.com/now
create function nnn.now(out body text) as $$
begin
	body = o.template('nnn-wrap', 'nnn-now',
		jsonb_build_object('pagetitle',
			'nownownow.com is doing what, now?'));
end;
$$ language plpgsql;
