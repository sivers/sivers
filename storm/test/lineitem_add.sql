insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (3, 'Cat');
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (3, 'cat@cat.cat');
insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('GB', 'United Kingdom');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);
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
insert into invoices (id, person_id, created, currency, total, status) values (4, 3, '2025-11-14', 'GBP', 11, 'cart');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (4, 4, 1, 1, 11);

alter table lineitems alter column id restart with 5;

select plan(19);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.lineitem_add('BadCookieBadCookieBadCookieBadKK', 4, 3);

select is(head, e'303\r\nLocation: /invoice/4'),
	is(body, null)
from storm.lineitem_add('StormAdmin1StormAdmin1StormAdmin', 4, 2);

select is(2::bigint, count(*)) from lineitems;

select is(invoice_id, 4),
	is(item_id, 2::smallint),
	is(quantity, 1::smallint),
	is(price, 3::numeric)
from lineitems where id = 5;

-- trigger intercepts:

select is(head, e'303\r\nLocation: /invoice/4'),
	is(body, null, 'adding identical should instead increase quantity')
from storm.lineitem_add('StormAdmin1StormAdmin1StormAdmin', 4, 2);

select is(2::bigint, count(*), 'still only two') from lineitems;

select is(quantity, 2::smallint, 'increased quantity'),
	is(price, 6::numeric, 'and price')
from lineitems where id = 5;

select is(head, e'303\r\nLocation: /invoice/4'),
	is(body, null, 'adding another digital does nothing')
from storm.lineitem_add('StormAdmin1StormAdmin1StormAdmin', 4, 1);

select is(2::bigint, count(*), 'still only two!') from lineitems;

select is(quantity, 1::smallint),
	is(price, 11::numeric)
from lineitems where id = 4;

