create function peep.loginform(
	out head text, out body text) as $$
begin
	body = o.template('peep-wrap', 'loginform', '{}');
end;
$$ language plpgsql;

