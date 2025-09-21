create function nnn.random(out body text) as $$
begin
	body = o.template('nnn-random', jsonb_build_object('jsurls', (
		select concat(
			e'const urls = [\n',
			string_agg('"' || long || '"', e',\n' order by long),
			'];')
		from now_pages
	)));
end;
$$ language plpgsql;
