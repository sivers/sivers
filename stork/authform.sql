create function storm.authform(
	out head text, out body text) as $$
begin
	body = o.template('storm-wrap', 'storm-authform', '{}'::jsonb);
end;
$$ language plpgsql;

