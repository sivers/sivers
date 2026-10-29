insert into countries (code, name) values ('NZ', 'New Zealand');
insert into countries (code, name) values ('AU', 'Australia');
insert into countries (code, name) values ('US', 'U.S.A.');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', now(), $$select concat('USD $', trim(to_char(AMOUNT, '999G990')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('NZD', now(), $$select concat('NZD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'New Zealand Dollars', 1.8);
insert into currencies (code, fxdate, fmt, name, fx) values ('AUD', now(), $$select concat('AUD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Australian Dollars', 1.6);

insert into ips (range, country) values ('[33554432,33751040)', 'NZ');
insert into ips (range, country) values ('[235012096,235012864)', 'AU');

insert into country_currency (country, currency) values ('NZ', 'NZD');
insert into country_currency (country, currency) values ('AU', 'AUD');

select plan(12);

select is(country, 'NZ', 'NZ ip found in lookup'),
	is(country_name, 'New Zealand'),
	is(currency, 'NZD'),
	is(currency_name, 'New Zealand Dollars')
from o.ipcc('2.0.0.2'); 

select is(country, 'AU', 'AU ip found in lookup'),
	is(country_name, 'Australia'),
	is(currency, 'AUD'),
	is(currency_name, 'Australian Dollars')
from o.ipcc('14.2.2.4'); 

select is(country, 'US', 'ip not found'),
	is(country_name, 'U.S.A.'),
	is(currency, 'USD'),
	is(currency_name, 'US Dollars')
from o.ipcc('123.123.123.123'); 

