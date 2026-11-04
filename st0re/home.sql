-- sive.rs/store
create function st0re.home(_country char(2), _currency char(3), _cart text,
	out head text, out body text) as $$
begin
	body = o.template('me-wrap', 'st0re-home', jsonb_build_object(
		'pagetitle', 'buy Derek Sivers books',
		'country', $1,
		'currency', $2,
		'cart', $3
	));
end;
$$ language plpgsql;

