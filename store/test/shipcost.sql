insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx, round2) values ('JPY', '2025-12-31', $$select concat('¥', trim(to_char(AMOUNT, '9G999G990')), ' (JPY)')$$, 'Japanese Yen', 150, 0);

insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into postrates (zone, books, currency, amount) values (1, 2, 'USD', 11.13);
insert into postrates (zone, books, currency, amount) values (1, 3, 'USD', 13.39);
insert into postrates (zone, books, currency, amount) values (1, 4, 'USD', 15.66);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);

insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (11, 1, 't', 'one_HC', 'Book One (hardcover)', 1002, 1);

insert into people (id, name) values (1, 'Mr. One');
insert into invoices (id, person_id, currency, warehouse, country) values (1, 1, 'CAD', 'US', 'CA');

select plan(54);

select is(store.shipcost(999), null::numeric, 'missing invoice');
select is(store.shipcost(null), null::numeric, 'null invoice');
select is(store.shipcost(1), 0::numeric, 'empty invoice');

insert into lineitems (id, invoice_id, item_id) values (100, 1, 11);
select is(store.shipcost(1), 11.52::numeric, 'one book converted to CAD');

-- For testing only, postrates only up to 4 books, to test splitting larger quantities into smaller boxes, combined cost

update invoices set currency = 'USD' where id = 1;
update lineitems set quantity = 1 where id = 100;
select is(store.shipcost(1), 8.86::numeric, 'USD quantity 1');
update lineitems set quantity = 2 where id = 100;
select is(store.shipcost(1), 11.13::numeric, 'USD quantity 2');
update lineitems set quantity = 3 where id = 100;
select is(store.shipcost(1), 13.39::numeric, 'USD quantity 3');
update lineitems set quantity = 4 where id = 100;
select is(store.shipcost(1), 15.66::numeric, 'USD quantity 4');
update lineitems set quantity = 5 where id = 100;
select is(store.shipcost(1), 24.52::numeric, 'USD quantity 5');
update lineitems set quantity = 6 where id = 100;
select is(store.shipcost(1), 26.79::numeric, 'USD quantity 6');
update lineitems set quantity = 7 where id = 100;
select is(store.shipcost(1), 29.05::numeric, 'USD quantity 7');
update lineitems set quantity = 8 where id = 100;
select is(store.shipcost(1), 31.32::numeric, 'USD quantity 8');
update lineitems set quantity = 9 where id = 100;
select is(store.shipcost(1), 40.18::numeric, 'USD quantity 9');
update lineitems set quantity = 10 where id = 100;
select is(store.shipcost(1), 42.45::numeric, 'USD quantity 10');
update lineitems set quantity = 11 where id = 100;
select is(store.shipcost(1), 44.71::numeric, 'USD quantity 11');
update lineitems set quantity = 12 where id = 100;
select is(store.shipcost(1), 46.98::numeric, 'USD quantity 12');
update lineitems set quantity = 13 where id = 100;
select is(store.shipcost(1), 55.84::numeric, 'USD quantity 13');

update invoices set currency = 'CAD' where id = 1;
update lineitems set quantity = 1 where id = 100;
select is(store.shipcost(1), 11.52::numeric, 'CAD quantity 1');
update lineitems set quantity = 2 where id = 100;
select is(store.shipcost(1), 14.47::numeric, 'CAD quantity 2');
update lineitems set quantity = 3 where id = 100;
select is(store.shipcost(1), 17.41::numeric, 'CAD quantity 3');
update lineitems set quantity = 4 where id = 100;
select is(store.shipcost(1), 20.36::numeric, 'CAD quantity 4');
update lineitems set quantity = 5 where id = 100;
select is(store.shipcost(1), 31.88::numeric, 'CAD quantity 5');
update lineitems set quantity = 6 where id = 100;
select is(store.shipcost(1), 34.83::numeric, 'CAD quantity 6');
update lineitems set quantity = 7 where id = 100;
select is(store.shipcost(1), 37.77::numeric, 'CAD quantity 7');
update lineitems set quantity = 8 where id = 100;
select is(store.shipcost(1), 40.72::numeric, 'CAD quantity 8');
update lineitems set quantity = 9 where id = 100;
select is(store.shipcost(1), 52.24::numeric, 'CAD quantity 9');
update lineitems set quantity = 10 where id = 100;
select is(store.shipcost(1), 55.19::numeric, 'CAD quantity 10');
update lineitems set quantity = 11 where id = 100;
select is(store.shipcost(1), 58.13::numeric, 'CAD quantity 11');
update lineitems set quantity = 12 where id = 100;
select is(store.shipcost(1), 61.08::numeric, 'CAD quantity 12');
update lineitems set quantity = 13 where id = 100;
select is(store.shipcost(1), 72.60::numeric, 'CAD quantity 13');

update invoices set currency = 'JPY' where id = 1;
update lineitems set quantity = 1 where id = 100;
select is(store.shipcost(1), 1329::numeric, 'JPY quantity 1');
update lineitems set quantity = 2 where id = 100;
select is(store.shipcost(1), 1670::numeric, 'JPY quantity 2');
update lineitems set quantity = 3 where id = 100;
select is(store.shipcost(1), 2009::numeric, 'JPY quantity 3');
update lineitems set quantity = 4 where id = 100;
select is(store.shipcost(1), 2349::numeric, 'JPY quantity 4');
update lineitems set quantity = 5 where id = 100;
select is(store.shipcost(1), 3678::numeric, 'JPY quantity 5');
update lineitems set quantity = 6 where id = 100;
select is(store.shipcost(1), 4019::numeric, 'JPY quantity 6');
update lineitems set quantity = 7 where id = 100;
select is(store.shipcost(1), 4358::numeric, 'JPY quantity 7');
update lineitems set quantity = 8 where id = 100;
select is(store.shipcost(1), 4698::numeric, 'JPY quantity 8');
update lineitems set quantity = 9 where id = 100;
select is(store.shipcost(1), 6027::numeric, 'JPY quantity 9');
update lineitems set quantity = 10 where id = 100;
select is(store.shipcost(1), 6368::numeric, 'JPY quantity 10');
update lineitems set quantity = 11 where id = 100;
select is(store.shipcost(1), 6707::numeric, 'JPY quantity 11');
update lineitems set quantity = 12 where id = 100;
select is(store.shipcost(1), 7047::numeric, 'JPY quantity 12');
update lineitems set quantity = 13 where id = 100;
select is(store.shipcost(1), 8376::numeric, 'JPY quantity 13');

update invoices set currency = 'CAD' where id = 1;
update lineitems set quantity = 9 where id = 100;
select is(store.shipcost(1), 52.24::numeric, 'two full boxes plus remainder, rounded per box');

update items set weight = 0 where id = 11;
select is(store.shipcost(1), 0::numeric, 'digital-only invoice');

update items set weight = 0.5 where id = 11;
select is(store.shipcost(1), 31.88::numeric, '4.5 total weight rounds to five books');

update items set weight = 1 where id = 11;
delete from postrates where zone = 1 and books = 1;
select is(store.shipcost(1), null::numeric, 'missing remainder rate');

update lineitems set quantity = 1 where id = 100;
select is(store.shipcost(1), null::numeric, 'missing rate below largest box');

delete from postrates where zone = 1;
select is(store.shipcost(1), null::numeric, 'no rates in zone');

delete from postzones where warehouse = 'US' and country = 'CA';
select throws_ok('select store.shipcost(1)', 'P0001', 'country not in postzones: CA', 'unsupported destination');

update invoices set country = null where id = 1;
select is(store.shipcost(1), 0::numeric, 'missing destination');

-- Larger-box examples: $50 per 100 books, $42 per 80, and $20 per 30.
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 30, 'USD', 20);
insert into postrates (zone, books, currency, amount) values (1, 80, 'USD', 42);
insert into postrates (zone, books, currency, amount) values (1, 100, 'USD', 50);
update invoices set currency = 'USD', country = 'CA' where id = 1;

update lineitems set quantity = 180 where id = 100;
select is(store.shipcost(1), 92::numeric, '180 books: one 100-book box plus one 80-book box');

update lineitems set quantity = 230 where id = 100;
select is(store.shipcost(1), 120::numeric, '230 books: two 100-book boxes plus one 30-book box');

-- Set the warehouse while digital so the repricing trigger does not fill it in.
update items set weight = 0 where id = 11;
update invoices set warehouse = null where id = 1;
update items set weight = 1 where id = 11;
select is(store.shipcost(1), 0::numeric, 'missing warehouse with physical items');

