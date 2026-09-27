insert into countries (code, name) values ('US', 'U.S.A.');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into warehouses (country) values ('US');

insert into prices (id, base, info, usd, cad) values (1000, 'USD', 'free', 0, 0);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into metaitems (id, name, price_id) values (2, 'Book Two', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (21, 2, 'two_HC', 'Book Two (hardcover)', 1002, 1);

insert into people (id, name) values (1, 'Mr. One');
insert into people (id, name) values (2, 'Mr. Two');
insert into invoices (id, person_id, currency) values (1, 1, 'USD');
insert into invoices (id, person_id, currency) values (2, 1, 'CAD');
insert into invoices (id, person_id, currency) values (3, 2, 'USD');

select plan(25);

select is(count(*)::integer, 0, 'missing invoice') from store.lineitems_liveprices(999);
select is(count(*)::integer, 0, 'null invoice') from store.lineitems_liveprices(null);
select is(count(*)::integer, 0, 'empty invoice') from store.lineitems_liveprices(1);

insert into lineitems (id, invoice_id, item_id, quantity) values (100, 1, 11, 2);
select is(lineitem_id, 100),
	is(liveprice, 23::numeric, 'two hardcovers: 2 * 4 + 15, base price charged once')
from store.lineitems_liveprices(1);

update lineitems set quantity = 3 where id = 100;
select is(liveprice, 27::numeric, 'quantity change multiplies item price, not base price')
from store.lineitems_liveprices(1);

insert into lineitems (id, invoice_id, item_id) values (99, 1, 21);
insert into lineitems (id, invoice_id, item_id) values (101, 1, 10);
select is(array_agg(lineitem_id), array[99, 100, 101], 'ordered by lineitem ID'),
	is(array_agg(liveprice), array[19, 27, 0]::numeric[], 'each book has its own base price; another format does not repeat it')
from store.lineitems_liveprices(1);

update invoices set currency = 'CAD' where id = 1;
select is(array_agg(liveprice), array[27.25, 38.75, 0]::numeric[], 'uses CAD prices for both items and metaitems')
from store.lineitems_liveprices(1);

insert into lineitems (id, invoice_id, item_id, quantity) values (102, 2, 11, 2);
select is(lineitem_id, 102, 'only returns the requested invoice'),
	is(liveprice, 11.50::numeric, 'another unpaid invoice for the same book pays only item costs')
from store.lineitems_liveprices(2);

update invoices set paydate = '2026-08-02' where id = 2;
select is(array_agg(liveprice), array[27.25, 17.25, 0]::numeric[], 'paid invoice takes the base charge away from the unpaid invoice')
from store.lineitems_liveprices(1);
select is(liveprice, 33::numeric, 'paid invoice now includes the base price')
from store.lineitems_liveprices(2);

insert into lineitems (id, invoice_id, item_id) values (103, 3, 11);
select is(lineitem_id, 103),
	is(liveprice, 19::numeric, 'another person still pays the base price in their invoice currency')
from store.lineitems_liveprices(3);

update prices set cad = 6 where id = 1002;
select is(array_agg(liveprice), array[27.5, 18, 0]::numeric[], 'current item prices are multiplied by quantity')
from store.lineitems_liveprices(1);
select is(liveprice, 33.5::numeric, 'current item prices also apply to paid invoices')
from store.lineitems_liveprices(2);

update prices set cad = 22 where id = 1001;
select is(array_agg(liveprice), array[28, 18, 0]::numeric[], 'current base price changes only the line charged for that book')
from store.lineitems_liveprices(1);
select is(liveprice, 34::numeric, 'current base price also applies to the paid invoice')
from store.lineitems_liveprices(2);

update lineitems set price = 999 where id = 102;
select is(liveprice, 34::numeric, 'live price ignores stored lineitem price')
from store.lineitems_liveprices(2);
select is(price, 999::numeric, 'reading live prices does not update stored prices')
from lineitems where id = 102;

update prices set cad = null where id = 1002;
select is(liveprice, 22::numeric, 'missing item price contributes zero')
from store.lineitems_liveprices(2);
update prices set cad = null where id = 1001;
select is(liveprice, 0::numeric, 'missing base price also contributes zero')
from store.lineitems_liveprices(2);

insert into lineitems (id, invoice_id, item_id) values (98, 3, 10);
select is(array_agg(lineitem_id), array[98, 103]),
	is(array_agg(liveprice), array[15, 4]::numeric[], 'digital item can carry the base price, leaving only the hardcover cost')
from store.lineitems_liveprices(3);

