-- don't need all these values but not-null column defs required it
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

select plan(3);

select is(o.money2('CAD', 15, 'CAD'), 15::numeric);
select is(o.money2('USD', 30, 'CAD'), 39::numeric);
select is(o.money2('EUR', 40, 'CAD'), 65::numeric);
