insert into countries (code, name) values ('US', 'U.S.A.');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into warehouses (country) values ('US');

insert into people (id, name) values (1, 'Mr. One');
insert into people (id, name) values (2, 'Mr. Two');

insert into prices (id, base, info, usd) values (1000, 'USD', 'free', 0);
insert into prices (id, base, info, usd) values (1001, 'USD', 'metaitem', 15);
insert into prices (id, base, info, usd) values (1002, 'USD', 'hardcover', 4);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into metaitems (id, name, price_id) values (2, 'Book Two', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (20, 2, 'two', 'Book Two (digital)', 1000, 0);

insert into invoices (id, person_id) values (1, 1);
insert into invoices (id, person_id) values (2, 1);
insert into invoices (id, person_id, paydate) values (3, 2, '2026-08-01');

select plan(17);

select is(count(*)::integer, 0, 'missing person') from store.access_paid(999);
select is(count(*)::integer, 0, 'null person') from store.access_paid(null);
select is(count(*)::integer, 0, 'no lineitems') from store.access_paid(1);

insert into lineitems (id, invoice_id, item_id) values (100, 1, 10);
insert into lineitems (id, invoice_id, item_id) values (101, 1, 11);
insert into lineitems (id, invoice_id, item_id) values (102, 2, 10);

select is(metaitem_id, 1::smallint),
	is(lineitem_id, 100, 'unpaid invoices use lowest lineitem ID across formats and invoices')
from store.access_paid(1);

insert into lineitems (id, invoice_id, item_id) values (99, 3, 10);
select is(metaitem_id, 1::smallint),
	is(lineitem_id, 100, 'another person buying the same book does not count')
from store.access_paid(1);

select is(metaitem_id, 1::smallint),
	is(lineitem_id, 99, 'other person gets their own lineitem')
from store.access_paid(2);

update invoices set paydate = '2026-08-03' where id = 2;
select is(metaitem_id, 1::smallint),
	is(lineitem_id, 102, 'paid invoice takes precedence over lower unpaid lineitem ID')
from store.access_paid(1);

update invoices set paydate = '2026-08-02' where id = 2;
update invoices set paydate = '2026-08-03' where id = 1;
select is(metaitem_id, 1::smallint),
	is(lineitem_id, 102, 'earliest payment date wins over lower lineitem ID')
from store.access_paid(1);

update invoices set paydate = '2026-08-02' where id = 1;
select is(metaitem_id, 1::smallint),
	is(lineitem_id, 100, 'same payment date uses lowest lineitem ID')
from store.access_paid(1);

insert into lineitems (id, invoice_id, item_id) values (98, 1, 20);
select is(array_agg(metaitem_id), array[1, 2]::smallint[], 'ordered by metaitem ID'),
	is(array_agg(lineitem_id), array[100, 98], 'one lineitem per metaitem')
from store.access_paid(1);

