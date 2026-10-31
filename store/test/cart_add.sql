insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into prices (id, base, info, usd) values (1000, 'USD', 'free', 0);
insert into prices (id, base, info, usd) values (1001, 'USD', 'metaitem', 15);
insert into prices (id, base, info, usd) values (1002, 'USD', 'hardcover', 4);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into metaitems (id, name, price_id) values (2, 'Book Two', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (20, 2, 'two', 'Book Two (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (21, 2, 'two_HC', 'Book Two (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight, available) values (22, 2, 'two_XX', 'Book Two (out of stock)', 1002, 1, false);

select plan(15);

select is(store.cart_add(11, 1, null), '11-1', 'add 1 11 to nothing');
select is(store.cart_add(11, 1, ''), '11-1', 'add 1 11 to nothing');
select is(store.cart_add(91, 1, ''), '', 'add invalid to nothing');
select is(store.cart_add(22, 1, ''), '', 'add unavailable to nothing');
select is(store.cart_add(11, 1, 'xxxx'), '11-1', 'add 1 11 to invalid cart');
select is(store.cart_add(11, 1, '21-1'), '21-1,11-1', 'add 1 11 to 11-1');
select is(store.cart_add(11, 80, '11-1'), '11-81', 'add 80 11 to 11-1');
select is(store.cart_add(22, 1, '11-1'), '11-1', 'unavailable item not added');
select is(store.cart_add(11, 1, '22-1'), '11-1', 'unavailable item removed');
select is(store.cart_add(11, 0, '22-1'), '', 'unavailable item removed even with nothing new added');
select is(store.cart_add(11, 1, '22-1,11-1'), '11-2', 'unavailable item removed, new updated');
select is(store.cart_add(11, 1, '20-1,22-1,11-1'), '20-1,11-2', 'unavailable removed, old kept, new updated');
select is(store.cart_add(10, 9, '10-1'), '10-1', 'digital max quantity 1');
select is(store.cart_add(11, -1, '11-1'), '11-1', 'negative quantity ignored');
select is(store.cart_add(11, 0, '21-1'), '21-1', 'zero quantity ignored'); 

