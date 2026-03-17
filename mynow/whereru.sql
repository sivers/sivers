create function mynow.whereru(kk char(32),
	out head text, out body text) as $$
declare
	pid integer;
	data jsonb;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		data = to_json(r) from (
			select name, city, state, country,
			o.select_country(country) as countries,
			o.select_state(country, state)::text as states
			from people
			where id = pid
		) r;
		body = o.template('mynow-wrap', 'mynow-whereru', data);
	end if;
end;
$$ language plpgsql;

