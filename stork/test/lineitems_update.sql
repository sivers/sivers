insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);

insert into people (id, name) values (1, 'Mr. One');

insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into metaitems (id, name, price_id) values (2, 'Book Two', 1001);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (11, 1, 't', 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (21, 2, 't', 'two_HC', 'Book Two (hardcover)', 1002, 1);

insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into postrates (zone, books, currency, amount) values (1, 2, 'USD', 11.13);
insert into postrates (zone, books, currency, amount) values (1, 3, 'USD', 13.39);
insert into postrates (zone, books, currency, amount) values (1, 4, 'USD', 15.66);

insert into invoices (id, person_id, currency, warehouse, country)
values (1, 1, 'CAD', 'US', 'CA');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (100, 1, 11, 1, 27.25);
insert into lineitems (id, invoice_id, item_id, quantity, price) values (101, 1, 21, 2, 33);

select plan(5);

select is(head, e'303\r\nLocation: /invoice/1'),
	is(body, null, 'redirecting to /invoice/1')
from stork.lineitems_update(1, '[
	{"id":100, "quantity":2},
	{"id":101, "quantity":0}
]'::jsonb);

select is(quantity, 2::smallint, 'quantity updated')
from lineitems where id = 100;

select is(count(*)::integer, 0, 'zero quantity deletes lineitem')
from lineitems where id = 101;

select is(count(*)::integer, 1, 'one lineitem remains on invoice')
from lineitems where invoice_id = 1;
