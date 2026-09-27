insert into countries (code, name) values ('US', 'U.S.A.');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into warehouses (country) values ('US');

insert into people (id, name) values (1, 'Mr. One');

insert into prices (id, base, info, usd) values (1000, 'USD', 'free', 0);
insert into prices (id, base, info, usd) values (1001, 'USD', 'metaitem', 15);
insert into prices (id, base, info, usd) values (1002, 'USD', 'hardcover', 4);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);

insert into invoices (id, person_id) values (1, 1);
insert into invoices (id, person_id) values (2, 1);

select plan(8);

select is(store.invoice_is_physical(999), false, 'missing invoice');
select is(store.invoice_is_physical(null), false, 'null invoice');
select is(store.invoice_is_physical(1), false, 'empty invoice');

insert into lineitems (id, invoice_id, item_id) values (100, 1, 10);
select is(store.invoice_is_physical(1), false, 'digital-only invoice');

insert into lineitems (id, invoice_id, item_id) values (101, 2, 11);
select is(store.invoice_is_physical(2), true, 'physical-only invoice');
select is(store.invoice_is_physical(1), false, 'physical item on another invoice does not count');

insert into lineitems (id, invoice_id, item_id) values (102, 1, 11);
select is(store.invoice_is_physical(1), true, 'mixed digital and physical invoice');

delete from lineitems where id = 102;
select is(store.invoice_is_physical(1), false, 'last physical item removed');

