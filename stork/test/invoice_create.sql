insert into countries (code, name) values ('US', 'U.S.A.');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);

insert into people (id, name) values (1, 'Mr. One');
insert into ats (person_id, email) values (1, 'one@one.com');

insert into prices (id, base, info, usd, cad) values (1000, 'USD', 'free', 0, 0);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (10, 1, 't', 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (11, 1, 't', 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'US', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 5);

insert into invoices
(id, person_id, created, currency, warehouse, shipcost, total, status)
values
(9, 1, '2026-08-01', 'USD', 'US', 5, 24, 'cart');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (90, 9, 11, 1, 19);

alter table invoices alter column id restart with 10;

select plan(8);

select is(count(*)::integer, 1) from invoices;

select is(head, e'303\r\nLocation: /invoice/9'),
	is(body, null, 'uses open cart invoice first')
from stork.invoice_create(1);

select is(count(*)::integer, 1) from invoices;

update invoices set status = 'hold' where id = 9;

select is(head, e'303\r\nLocation: /invoice/10'),
	is(body, null, 'creates new invoice if no cart')
from stork.invoice_create(1);

select is(count(*)::integer, 2) from invoices;

select is(person_id, 1) from invoices where id = 10;
