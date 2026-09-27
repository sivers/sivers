create function stork.preship_see(
	out head text, out body text) as $$
begin
	body = o.template('stork-wrap', 'stork-preship',
		jsonb_build_object('items', stork.preship()));
end;
$$ language plpgsql;

