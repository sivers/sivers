insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (2, 'Boo');
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (2, 'boo@boo.boo');
insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('BE', 'Belgium');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('EUR', 'Euros', 'select concat(trim(to_char(AMOUNT, ''999G990D00'')), '' € (EUR)'')', 0.860704, '2025-10-10', 2);
insert into warehouses (country, address) values ('US', '123 Warehouse Street');
insert into prices (id, base, info, usd, cad, eur, gbp) values (0, 'USD', 'free', 0, 0, 0, 0);
insert into prices (id, base, info, usd, cad, eur, gbp) values (1, 'USD', 'meta', 15, 21, 13, 11);
insert into prices (id, base, info, usd, cad, eur, gbp) values (2, 'USD', 'hard', 4, 5, 3.5, 3);
insert into metaitems (id, name, price_id) values (1, 'one', 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (1, 1, 'one-digi', 'one digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (2, 1, 'one-hard', 'one hardcover', 2, 1);
insert into invoices (id, person_id, created, currency, warehouse, shipcost, total, payment, paydate, payinfo, status, shipdate, shipinfo, shipname, addr1, addr2, city, state, postcode, country, phone, gift_note) values (1, 2, '2025-11-11', 'EUR', 'US', 3.5, 23.5, 23.5, '2025-11-11', 'one-blah', 'done', '2025-11-12', 'shipinfo1', 'Boo', 'Boo Str 1', null, 'Booville', null, 'boo123', 'BE', '+33445566', 'gift message');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (1, 1, 2, 2, 7); -- physical should copy
insert into lineitems (id, invoice_id, item_id, quantity, price) values (2, 1, 1, 1, 13); -- digital should not copy

alter table invoices alter column id restart with 2;
alter table lineitems alter column id restart with 3;

select plan(18);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.invoice_reship('BadCookieBadCookieBadCookieBadKK', 1);

select is(head, e'303\r\nLocation: /invoice/2'),
	is(body, null)
from storm.invoice_reship('StormAdmin1StormAdmin1StormAdmin', 1);

select is(2::bigint, count(*), 'only copied invoice once')
from invoices;

select is(3::bigint, count(*), 'only copied physical line')
from lineitems;

select is(invoice_id, 2),
	is(item_id, 2::smallint),
	is(quantity, 2::smallint),
	is(price, 7::numeric)
from lineitems where id = 3;

select is(person_id, 2),
	is(currency, 'EUR'),
	is(warehouse, 'US'),
	is(total, 23.5::numeric),
	is(status, 'ship'),
	is(payment, 23.5::numeric),
	is(payinfo, 'reship of 1'),
	is(gift_note, 'gift message')
from invoices where id = 2;
