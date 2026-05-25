-- don't need all these values but not-null column defs required it
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

insert into prices (id, base, info, usd, cad, eur) values (1001, 'USD', 'metaitem', 15, 21.5, 14);
insert into prices (id, base, info, usd, cad, eur) values (1002, 'USD', 'paper', 4, 5.75, 3.75);
select plan(5);

select is(o.price('USD', 999::smallint), 0::numeric);
select is(o.price('XXX', 1001::smallint), 0::numeric);
select is(o.price('USD', 1001::smallint), 15::numeric);
select is(o.price('EUR', 1001::smallint), 14::numeric);
select is(o.price('CAD', 1002::smallint), 5.75::numeric);
