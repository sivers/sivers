-- validate info in cookies
-- if country or currency missing or wrong, set correctly from IP
-- remove invalid or unavailable items from cart
-- NOTE: no body, not a regular WebDB function! Only for middleware cookies.
create function store.valid8(_country char(2), _currency char(3), _cart text, _ip inet,
	out head text) as $$
declare
	oo constant text = '; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800';
	cr text;
begin
	if $1 = '' or $2 = ''
	or not exists (select 1 from countries where code = $1)
	or not exists (select 1 from currencies where code = $2)
	then
		select format(e'Set-Cookie: country=%s%s\r\nSet-Cookie: currency=%s%s', country, oo, currency, oo)
		into head
		from o.ipcc(_ip);
	end if;
	-- add nothing to cart_add, just for its cart validation that removes invalid or unavailable items
	if $3 != '' then
		cr = store.cart_add(0, 0, $3);
		-- only if cart string changed, set new cookie
		if cr != $3 then
			head = concat_ws(e'\r\n', head, 'Set-Cookie: cart=' || cr || oo);
		end if;
	end if;
end;
$$ language plpgsql stable;

