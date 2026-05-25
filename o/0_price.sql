-- given currency and prices.id, return numeric price
-- (weird hack using the jsonb lower to get the lowercase column value)
create function o.price(_currency char(3), _price_id smallint) returns numeric as $$
	select coalesce((
		select (to_jsonb(prices) ->> lower(currencies.code))::numeric
		from currencies
		join prices on prices.id = $2
		where currencies.code = $1
	), 0);
$$ language sql;
