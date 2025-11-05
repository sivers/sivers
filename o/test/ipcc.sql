insert into people(id, name) values (1, 'Me');
insert into people(id, name) values (2, 'Her');
insert into people(id, name) values (3, 'Other');

insert into countries (code, name) values ('NZ', 'New Zealand');
insert into countries (code, name) values ('AU', 'Australia');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', now(), $$select concat('USD $', trim(to_char(AMOUNT, '999G990')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('NZD', now(), $$select concat('NZD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'New Zealand Dollars', 1.8);
insert into currencies (code, fxdate, fmt, name, fx) values ('AUD', now(), $$select concat('AUD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Australian Dollars', 1.6);

insert into stats (person_id, statkey, statvalue) values (2, 'country', 'AU');

insert into ips (ip1, ip2, country) values ('1.0.0.0', '1.0.0.254', 'AU');
insert into ips (ip1, ip2, country) values ('2.0.0.0', '2.0.0.254', 'NZ');

insert into country_currency (country, currency) values ('NZ', 'NZD');
insert into country_currency (country, currency) values ('AU', 'AUD');

select plan(14);

select is(country, 'NZ', 'ip found in lookup'),
	is(country_name, 'New Zealand'),
	is(currency, 'NZD'),
	is(currency_name, 'New Zealand Dollars')
from o.ipcc(1, '2.0.0.2'); 

select is(statvalue, 'NZ', 'country cached now')
from stats where person_id = 1 and statkey = 'country';

select is(country, 'AU', 'ip ignored because country in cache'),
	is(country_name, 'Australia'),
	is(currency, 'AUD'),
	is(currency_name, 'Australian Dollars')
from o.ipcc(2, '99.99.99.99'); 

select is(country, 'XX', 'ip not found'),
	is(country_name, null),
	is(currency, 'USD'),
	is(currency_name, 'US Dollars')
from o.ipcc(3, '123.123.123.123'); 

select is(count(*)::integer, 0, 'country not cached if XX')
from stats where person_id = 3 and statkey = 'country';

