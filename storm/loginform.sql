create function storm.loginform(
	out head text, out body text) as $$
begin
	body = o.template('storm-wrap', 'loginform', '{}');
end;
$$ language plpgsql;

