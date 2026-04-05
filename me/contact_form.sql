create function me.contact_form(_ip inet,
	out head text, out body text) as $$
declare
	data jsonb;
	ip inet;
begin
	data = to_json(r) from (
		select host($1) as ip, city, state, country,
		o.select_country(country) as countries,
		o.select_state(country, state)::text as states
		from ips
		where range @> ($1 - '0.0.0.0'::inet)
	) r;
	body = o.template('me-wrap', 'me-contactform', data);
end;
$$ language plpgsql;

