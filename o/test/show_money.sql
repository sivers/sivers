insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('INR', '2025-12-31', $$select concat('₹', trim(to_char(AMOUNT, '99G99G990')))$$, 'Indian Rupees', 95.700504);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

select plan(4);

select is(o.show_money('CAD', 15.5), 'CAD $15.50');
select is(o.show_money('USD', 12.34), 'USD $12.34');
select is(o.show_money('EUR', 43.21), '43.21 € (EUR)');
select is(o.show_money('INR', 123456), '₹1,23,456');

