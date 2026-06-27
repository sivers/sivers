-- wonky hacky fun to format currency in PostgreSQL itself:
-- for each currency I have a "fmt" that's really a full command like this:
-- select concat('₹', trim(to_char(AMOUNT::numeric, '99G99G999')), ' (INR)')
-- so then I have to string-replace "AMOUNT" with the actual amount
-- then run the command and return the result.  (See tests for examples)
create function o.show_money(_currency char(3), _amount numeric, out show text) as $$
declare
	cmd text;
begin
	select replace(fmt, 'AMOUNT', concat(coalesce($2, 0), '::numeric')) into cmd
	from currencies
	where code = coalesce($1, 'USD'); -- if currency is null, use USD
	execute cmd into show;
end;
$$ language plpgsql;
