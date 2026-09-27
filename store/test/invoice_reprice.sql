insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into warehouses (country) values ('US');
insert into warehouses (country) values ('CA');
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postzones (warehouse, country, zone) values ('CA', 'CA', 2);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into postrates (zone, books, currency, amount) values (1, 2, 'USD', 11.13);
insert into postrates (zone, books, currency, amount) values (1, 3, 'USD', 13.39);
insert into postrates (zone, books, currency, amount) values (2, 1, 'USD', 11.13);

insert into prices (id, base, info, usd, cad) values (1000, 'USD', 'free', 0, 0);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);

insert into people (id, name) values (1, 'Mr. One');
insert into people (id, name) values (2, 'Mr. Two');
insert into invoices (id, person_id, currency, country, shipcost, total, payment)
values (1, 1, 'CAD', 'CA', 999, 999, 27.25);
insert into invoices (id, person_id, currency, warehouse, country)
values (2, 2, 'USD', 'CA', 'CA');

select plan(38);

select lives_ok('select store.invoice_reprice(999)', 'missing invoice is harmless');
select lives_ok('select store.invoice_reprice(null)', 'null invoice is harmless');

select store.invoice_reprice(1);
select is(warehouse, null, 'empty invoice needs no warehouse'),
	is(shipcost, 0::numeric, 'empty invoice has no shipping'),
	is(total, 0::numeric, 'empty invoice total is zero')
from invoices where id = 1;

insert into lineitems (id, invoice_id, item_id) values (100, 1, 10);
-- Overwrite prices after the triggers run, so the explicit call must repair them.
update lineitems set price = 999 where invoice_id = 1;
update invoices set shipcost = 999, total = 999 where id = 1;
select store.invoice_reprice(1);
select is(price, 21.5::numeric, 'digital item includes the base price in CAD')
from lineitems where id = 100;
select is(warehouse, null, 'digital-only invoice needs no warehouse'),
	is(shipcost, 0::numeric, 'digital-only invoice has no shipping'),
	is(total, 21.5::numeric, 'digital-only total uses the new lineitem price')
from invoices where id = 1;

insert into lineitems (id, invoice_id, item_id, quantity) values (101, 1, 11, 2);
insert into lineitems (id, invoice_id, item_id) values (102, 2, 11);
-- Clear the warehouse while digital so the trigger does not fill it in first.
update items set weight = 0 where id = 11;
update invoices set warehouse = null where id = 1;
update items set weight = 1 where id = 11;
update lineitems set price = 999 where invoice_id = 1;
update invoices set shipcost = 999, total = 999 where id = 1;
update lineitems set price = 777 where invoice_id = 2;
update invoices set shipcost = 777, total = 777 where id = 2;

select store.invoice_reprice(1);
select is(array_agg(price order by id), array[21.5, 11.5]::numeric[], 'updates every line, charging the base price once')
from lineitems where invoice_id = 1;
select is(warehouse, 'US'::char(2), 'physical invoice gets the default warehouse'),
	is(shipcost, 14.47::numeric, 'shipping is converted to CAD'),
	is(total, 47.47::numeric, 'total combines updated line prices and shipping'),
	is(payment, 27.25::numeric, 'payment is unchanged'),
	is(status, 'cart'::varchar, 'status is unchanged')
from invoices where id = 1;

select is(price, 777::numeric, 'another invoice lineitem is unchanged')
from lineitems where id = 102;
select is(shipcost, 777::numeric, 'another invoice shipping is unchanged'),
	is(total, 777::numeric, 'another invoice total is unchanged')
from invoices where id = 2;

select store.invoice_reprice(2);
select is(price, 19::numeric, 'other person pays their own base price in USD')
from lineitems where id = 102;
select is(warehouse, 'CA'::char(2), 'existing warehouse is preserved'),
	is(shipcost, 11.13::numeric, 'uses the existing warehouse shipping zone'),
	is(total, 30.13::numeric, 'other invoice total is recalculated')
from invoices where id = 2;

update prices set cad = 6 where id = 1002;
update prices set cad = 22 where id = 1001;
update postrates set amount = 10 where zone = 1 and books = 2;
select store.invoice_reprice(1);
select is(array_agg(price order by id), array[22, 12]::numeric[], 'uses current item and base prices')
from lineitems where invoice_id = 1;
select is(shipcost, 13::numeric, 'uses current postage rates'),
	is(total, 47::numeric, 'total uses all current prices')
from invoices where id = 1;

update invoices set currency = 'USD' where id = 1;
update lineitems set price = 999 where invoice_id = 1;
update invoices set shipcost = 999, total = 999 where id = 1;
select store.invoice_reprice(1);
select is(array_agg(price order by id), array[15, 8]::numeric[], 'reprices lineitems in the invoice currency')
from lineitems where invoice_id = 1;
select is(shipcost, 10::numeric, 'shipping uses the invoice currency'),
	is(total, 33::numeric, 'total uses the invoice currency')
from invoices where id = 1;

select store.invoice_reprice(1);
select is(array_agg(price order by id), array[15, 8]::numeric[], 'repeated repricing leaves line prices unchanged')
from lineitems where invoice_id = 1;
select is(shipcost, 10::numeric, 'repeated repricing leaves shipping unchanged'),
	is(total, 33::numeric, 'repeated repricing leaves total unchanged')
from invoices where id = 1;

-- A gap below the largest box size cannot be priced.
delete from postrates where zone = 1 and books = 2;
select store.invoice_reprice(1);
select is(shipcost, null::numeric, 'missing shipping rate clears old shipping cost'),
	is(total, null::numeric, 'unknown shipping makes the total unknown')
from invoices where id = 1;

delete from postzones where warehouse = 'US' and country = 'CA';
update lineitems set price = 999 where invoice_id = 1;
select throws_ok('select store.invoice_reprice(1)', 'P0001', 'country not in postzones: CA', 'unsupported destination raises the shipping error');
select is(array_agg(price order by id), array[999, 999]::numeric[], 'failed repricing rolls back lineitem updates')
from lineitems where invoice_id = 1;

insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
delete from lineitems where invoice_id = 1;
update invoices set shipcost = 999, total = 999 where id = 1;
select store.invoice_reprice(1);
select is(warehouse, 'US'::char(2), 'emptying an invoice preserves its warehouse'),
	is(shipcost, 0::numeric, 'removing all items clears shipping'),
	is(total, 0::numeric, 'removing all items clears total')
from invoices where id = 1;

