--- PRIVATE FUNCTION used for o.shipcost(_invid):
create function o.shipcost(_currency char(3), _warehouse char(2), _country char(2), _books int) returns numeric as $$
declare
	c numeric; -- query into this. return when not null.
	maxbooks int;
	booksleft int;
begin
	-- null warehouse or country or zero weight? return 0
	if $2 is null or $3 is null or $4 <= 0 or $4 is null then
		return 0;
	end if;

	-- warehouse+country combination not in zones? raise err
	if not exists (
		select 1 from postzones where warehouse = $2 and country = $3 limit 1
	) then
		raise exception 'country not in postzones: %', $3;
	end if;

	-- find warehouse + country + weight in their currency
	-- (money2 function doing the rounding to that currency's precision)
	select o.money2(postrates.currency, postrates.amount, $1) into c
	from postzones
	join postrates on postrates.zone = postzones.zone and postrates.books = $4
	where postzones.warehouse = $2
	and postzones.country = $3;
	if c is not null then
		return c;
	end if;

	-- no match? probably over max books, so break into boxes:
	-- for now I'm doing maximum + leftover, but could be smarter to do half + half
	select max(books) into maxbooks
	from postrates
	where postrates.zone = (
		select postzones.zone
		from postzones
		where postzones.warehouse = $2
		and postzones.country = $3
	);
	if $4 > maxbooks then
		select o.shipcost($1, $2, $3, maxbooks) into c; -- recursive!
		booksleft = $4 - maxbooks;
		while booksleft > maxbooks loop
			c = c + o.shipcost($1, $2, $3, maxbooks);
			booksleft = booksleft - maxbooks;
		end loop;
		if booksleft > 0 then
			c = c + o.shipcost($1, $2, $3, booksleft);
		end if;
	end if;
	return c;
end;
$$ language plpgsql;

-- given invoice_id, return above function, with the two values it needs
-- rounding again here just for the JPY/CNY/SEK currencies that want integers
create or replace function o.shipcost(_invid integer) returns numeric as $$
	select round(o.shipcost(i.currency, i.warehouse, i.country, i.weight::int), i.round2)
	from (
		select invoices.currency, warehouse, country, currencies.round2, (
			select sum(lineitems.quantity * items.weight)
			from lineitems
			join items on lineitems.item_id = items.id
			where lineitems.invoice_id = $1
		) as weight
		from invoices
		join currencies on invoices.currency = currencies.code
		where id = $1
	) as i;
$$ language sql;

