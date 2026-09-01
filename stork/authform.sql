create function stork.authform(
	out head text, out body text) as $$
begin
	body = o.template('stork-wrap', 'stork-authform', '{}'::jsonb);
end;
$$ language plpgsql;

