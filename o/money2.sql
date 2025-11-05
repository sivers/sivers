-- exchange amount ($2) from one currency ($1) to another ($3)
-- select o.money2('USD', 1234.56, 'CNY')
create function o.money2(_from char(3), _amt numeric, _to char(3),
	out amount numeric) as $$
begin
	-- if both currencies are the same, easy: just return $2
	if $1 = $3 then
		amount = $2;
	-- if $1 or $3 is USD, pretty easy: use currencies.fx once
	elsif $1 = 'USD' then
		select round($2 * fx, round2) into amount from currencies where code = $3;
	elsif $3 = 'USD' then
		select round($2 / fx, round2) into amount from currencies where code = $1;
	-- if neither is USD, convert to USD then to target
	else
		select round(($2 / c1.fx) * c2.fx, c2.round2) into amount
		from currencies c1, currencies c2
		where c1.code = $1 and c2.code = $3;
	end if;
end;
$$ language plpgsql stable;

