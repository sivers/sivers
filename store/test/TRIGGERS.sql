insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into warehouses (country) values ('US');
insert into warehouses (country) values ('CA');
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postzones (warehouse, country, zone) values ('CA', 'CA', 2);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into postrates (zone, books, currency, amount) values (2, 1, 'USD', 11.13);

insert into prices (id, base, info, usd, cad) values (1000, 'USD', 'free', 0, 0);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);

insert into people (id, name) values (1, 'Mr. One');
insert into invoices (id, person_id, currency, warehouse, country) values (1, 1, 'USD', 'US', 'CA');

select plan(22);

-- trig_lineitems_recalc: inserting a line reprices it and its invoice.
insert into lineitems (id, invoice_id, item_id) values (100, 1, 11);
select is(price, 19::numeric, 'insert calculates lineitem price') from lineitems where id = 100;
select is(total, 27.86::numeric, 'insert recalculates invoice total with shipping') from invoices where id = 1;

-- trig_invoice_recalc: currency, country, and warehouse changes reprice the invoice.
update invoices set currency = 'CAD' where id = 1;
select is(price, 27.25::numeric, 'currency change reprices lineitems') from lineitems where id = 100;
select is(total, 38.77::numeric, 'currency change reprices invoice total') from invoices where id = 1;

update invoices set country = null where id = 1;
select is(total, 27.25::numeric, 'country change removes shipping without a destination') from invoices where id = 1;

update invoices set country = 'CA' where id = 1;
update invoices set warehouse = 'CA' where id = 1;
select is(total, 41.72::numeric, 'warehouse change uses the new shipping zone') from invoices where id = 1;

-- trig_lineitems_recalc: updating and deleting a line also reprice the invoice.
update invoices set currency = 'USD', warehouse = 'US' where id = 1;
update lineitems set quantity = 2 where id = 100;
select is(total, 40.72::numeric, 'quantity update recalculates invoice total') from invoices where id = 1;

delete from lineitems where id = 100;
select is(total, 0::numeric, 'delete recalculates the old invoice total') from invoices where id = 1;

-- trig_lineitem_quant: physical quantities above one are kept.
insert into lineitems (id, invoice_id, item_id, quantity) values (100, 1, 11, 2);
select is(quantity, 2::smallint, 'multiple physical copies are allowed') from lineitems where id = 100;

-- Existing invoice/item combination: merge quantities instead of adding a row.
insert into lineitems (id, invoice_id, item_id, quantity) values (101, 1, 11, 3);
select is(quantity, 5::smallint, 'duplicate insert adds to existing quantity') from lineitems where id = 100;
select is(count(*)::integer, 1, 'duplicate insert leaves only one line') from lineitems where invoice_id = 1;

-- Digital quantities above one are reduced to one, on insert and update.
insert into lineitems (id, invoice_id, item_id, quantity) values (102, 1, 10, 3);
select is(quantity, 1::smallint, 'digital insert quantity is capped at one') from lineitems where id = 102;
update lineitems set quantity = 4 where id = 102;
select is(quantity, 1::smallint, 'digital update quantity is capped at one') from lineitems where id = 102;

insert into lineitems (id, invoice_id, item_id, quantity) values (103, 1, 10, 2);
select is(quantity, 1::smallint, 'merging digital quantities still caps at one') from lineitems where id = 102;
select is(count(*)::integer, 1, 'duplicate digital insert leaves one digital line') from lineitems where invoice_id = 1 and item_id = 10;

-- Updating a line to an existing item merges it and deletes the changed line.
update lineitems set item_id = 11 where id = 102;
select is(quantity, 6::smallint, 'duplicate update adds to existing quantity') from lineitems where id = 100;
select is(count(*)::integer, 0, 'duplicate update deletes the changed line') from lineitems where id = 102;

-- Quantities below one delete existing lines or prevent new lines.
update lineitems set quantity = 0 where id = 100;
select is(count(*)::integer, 0, 'zero quantity deletes existing line') from lineitems where id = 100;
insert into lineitems (id, invoice_id, item_id, quantity) values (104, 1, 11, 0);
select is(count(*)::integer, 0, 'zero quantity prevents insert') from lineitems where id = 104;
insert into lineitems (id, invoice_id, item_id, quantity) values (105, 1, 11, -1);
select is(count(*)::integer, 0, 'negative quantity prevents insert') from lineitems where id = 105;
insert into lineitems (id, invoice_id, item_id) values (106, 1, 11);
select is(quantity, 1::smallint, 'quantity one is kept') from lineitems where id = 106;
update lineitems set quantity = -1 where id = 106;
select is(count(*)::integer, 0, 'negative quantity deletes existing line') from lineitems where id = 106;

