insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (2, 'Boo Brown');
insert into people (id, name) values (3, 'Cat Brown');
insert into people (id, name) values (4, 'Dog Boomer');
insert into people (id, name) values (5, 'Boomer Brown Will Not Be Found'); -- searches customers only
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (2, 'boo@boo.boo');
insert into ats (person_id, email) values (3, 'cat@cat.cat');
insert into ats (person_id, email) values (4, 'dog@dog.dog');
insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');
insert into countries (code, name) values ('GB', 'United Kingdom');
insert into countries (code, name) values ('BE', 'Belgium');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('CAD', 'Canadian Dollars', 'select concat(''CAD $'', trim(to_char(AMOUNT, ''999G990D00'')))', 1.40175, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('EUR', 'Euros', 'select concat(trim(to_char(AMOUNT, ''999G990D00'')), '' € (EUR)'')', 0.860704, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('GBP', 'British Pounds', 'select concat(''GBP £'', trim(to_char(AMOUNT, ''999G990D00'')))', 0.748923, '2025-10-10', 2);
insert into warehouses (country, address) values ('US', '123 Warehouse Street');
insert into prices (id, base, info, usd, cad, eur, gbp) values (0, 'USD', 'free', 0, 0, 0, 0);
insert into prices (id, base, info, usd, cad, eur, gbp) values (1, 'USD', 'meta', 15, 21, 13, 11);
insert into prices (id, base, info, usd, cad, eur, gbp) values (2, 'USD', 'hard', 4, 5, 3.5, 3);
insert into metaitems (id, name, price_id) values (1, 'one', 1);
insert into metaitems (id, name, price_id) values (2, 'two', 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (1, 1, 'one-digi', 'one digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (2, 1, 'one-hard', 'one hardcover', 2, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (3, 2, 'two-digi', 'two digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (4, 2, 'two-hard', 'two hardcover', 2, 1);
insert into invoices (id, person_id, created, currency, warehouse, shipcost, total, payment, paydate, payinfo, status, shipdate, shipinfo, shipname, addr1, addr2, city, state, postcode, country, phone, gift_note) values (1, 2, '2025-11-11', 'EUR', 'US', 3.5, 20, 20, '2025-11-11', 'one-blah', 'hold', null, null, 'Boo', 'Boo Str 1', null, 'Booville', null, 'boo123', 'BE', '+33445566', null);
insert into invoices (id, person_id, created, currency, shipcost, total, payment, paydate, payinfo, status) values (2, 3, '2025-11-12', 'GBP', 0, 11, 11, '2025-11-12', 'two-blah', 'done');
insert into invoices (id, person_id, created, currency, warehouse, shipcost, total, payment, paydate, payinfo, status, shipdate, shipinfo, shipname, addr1, addr2, city, state, postcode, country, phone, gift_note) values (3, 4, '2025-11-13', 'CAD', 'US', 3, 29, 29, '2025-11-13', 'three-blah', 'ship', null, null, 'Dog', '4 Dog Street', 'Apt 4', 'Dogtown', 'BC', 'DOG123', 'CA', '+144332211', 'for mama');
insert into invoices (id, person_id, created, currency, total, status) values (4, 3, '2025-11-14', 'GBP', 11, 'cart');
insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-search', '
term:{{term}}
PEOPLE:
{{#people}}
id:{{id}}
name:{{name}}
emails:{{emails}}
{{/people}}
');

select plan(4);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.search('BadCookieBadCookieBadCookieBadKK', 'Brown');

select is(head, null),
	is(body, '<html>
term:boo
PEOPLE:
id:2
name:Boo Brown
emails:boo@boo.boo
id:4
name:Dog Boomer
emails:dog@dog.dog
</html>')
from storm.search('StormAdmin1StormAdmin1StormAdmin', 'boo');

select is(head, null),
	is(body, '<html>
term:Brown
PEOPLE:
id:2
name:Boo Brown
emails:boo@boo.boo
id:3
name:Cat Brown
emails:cat@cat.cat
</html>')
from storm.search('StormAdmin1StormAdmin1StormAdmin', ' Brown ');
