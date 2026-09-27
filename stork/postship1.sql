-- the empty form for uploading shipped CSV
create function stork.postship1(
	out head text, out body text) as $$
begin
	body = o.template('stork-wrap', 'stork-postship1', '{}'::jsonb);
end;
$$ language plpgsql;

