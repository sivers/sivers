insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);

insert into people (id, name) values (1, 'Mr. One');
insert into ats (person_id, email, used) values (1, 'one@one.com', '2026-08-01');
insert into ats (person_id, email, used) values (1, 'new@one.com', '2026-08-02');

insert into people (id, name) values (2, 'Mr. Two');
insert into ats (person_id, email, used) values (2, 'two@two.com', '2026-08-02');
insert into ats (person_id, email, used) values (2, 'old@two.com', '2026-08-01');
insert into ats (person_id, email, used) values (2, 'unused@two.com', null);

insert into prices (id, base, info, usd, cad) values (1000, 'USD', 'free', 0, 0);
insert into prices (id, base, info, usd, cad) values (1001, 'USD', 'metaitem', 15, 21.5);
insert into prices (id, base, info, usd, cad) values (1002, 'USD', 'hardcover', 4, 5.75);
insert into prices (id, base, info, usd, cad) values (1003, 'USD', 'paperback', 4, 5.75);
insert into prices (id, base, info, usd, cad) values (1004, 'USD', 'signed', 6, 8.5);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into metaitems (id, name, price_id) values (2, 'Book Two', 1001);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (10, 1, 't', 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (11, 1, 't', 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (12, 1, 't', 'one_PB', 'Book One (paperback)', 1003, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (13, 1, 'f', 'one_HCS', 'Book One (autographed)', 1004, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (14, 1, 't', 'one_HC_WRAP', 'Book One (gift wrapped)', 1002, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (20, 2, 't', 'two', 'Book Two (digital)', 1000, 0);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (21, 2, 't', 'two_HC', 'Book Two (hardcover)', 1002, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (22, 2, 'f', 'two_PB', 'Book Two (paperback)', 1003, 1);
insert into items (id, metaitem_id, available, sku, name, price_id, weight) values (23, 2, 't', 'two_HCS', 'Book Two (autographed)', 1004, 1);

insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into postrates (zone, books, currency, amount) values (1, 2, 'USD', 11.13);
insert into postrates (zone, books, currency, amount) values (1, 3, 'USD', 13.39);
insert into postrates (zone, books, currency, amount) values (1, 4, 'USD', 15.66);


select plan(5);

select is(stork.preship(), '[]'::jsonb, 'empty ok');

insert into invoices
(id, person_id, currency, warehouse, paydate, status, shipname, addr1, addr2,
city, state, postcode, country, phone, gift_note)
values
(1, 1, 'CAD', 'US', '2026-08-02', 'ship', 'One Person', '1 One St', 'Apt #1',
'Unoville', 'BC', 'V1B2C3', 'CA', '+1 604 123 4567', 'not a gift'),
(2, 1, 'CAD', 'US', '2026-08-03', 'ship', 'Gift Recipient', '2 Two St', null,
'Unoville', 'BC', 'V1B2C3', 'CA', null, 'Happy birthday!'),
(3, 2, 'CAD', 'US', '2026-08-04', 'ship', 'Two Person', '3 Three St', null,
'Unoville', 'BC', 'V1B2C3', 'CA', null, null),
(4, 1, 'CAD', 'US', '2026-08-01', 'done', 'One Person', '1 One St', null,
'Unoville', 'BC', 'V1B2C3', 'CA', null, null),
(5, 2, 'CAD', 'US', '2026-08-01', 'wait', 'Two Person', '3 Three St', null,
'Unoville', 'BC', 'V1B2C3', 'CA', null, null);

insert into lineitems (id, invoice_id, item_id, quantity) values (100, 1, 11, 1);
insert into lineitems (id, invoice_id, item_id, quantity) values (101, 1, 21, 2);
insert into lineitems (id, invoice_id, item_id, quantity) values (102, 1, 10, 1);
insert into lineitems (id, invoice_id, item_id, quantity) values (103, 2, 14, 1);
insert into lineitems (id, invoice_id, item_id, quantity) values (104, 3, 11, 2);
insert into lineitems (id, invoice_id, item_id, quantity) values (105, 4, 11, 1);
insert into lineitems (id, invoice_id, item_id, quantity) values (106, 5, 21, 1);

select is(jsonb_array_length(stork.preship()), 4, 'four physical items in 3 invoices');

select is((select jsonb_agg(jsonb_build_object(
	'invid', r -> 'invid', 'item_id', r -> 'item_id',
	'quantity', r -> 'quantity', 'howmany', r -> 'howmany',
	'email', r -> 'email', 'gift', r -> 'gift', 'gift_note', r -> 'gift_note'
) order by n) from jsonb_array_elements(stork.preship()) with ordinality as rows(r, n)),
'[
	{"invid":1, "item_id":11, "quantity":1, "howmany":2, "email":"new@one.com", "gift":"no", "gift_note":"not a gift"},
	{"invid":1, "item_id":21, "quantity":2, "howmany":2, "email":"new@one.com", "gift":"no", "gift_note":"not a gift"},
	{"invid":2, "item_id":14, "quantity":1, "howmany":2, "email":"new@one.com", "gift":"yes", "gift_note":"Happy birthday!"},
	{"invid":3, "item_id":11, "quantity":2, "howmany":1, "email":"two@two.com", "gift":"no", "gift_note":null}
]'::jsonb, 'ordered items, invoice counts, latest email per person, and gift wrapping');

select is(stork.preship() -> 0, '{
	"howmany":2,
	"item_id":11,
	"sku":"one_HC",
	"quantity":1,
	"invid":1,
	"paydate":"2026-08-02",
	"shipcost":17.41,
	"person_id":1,
	"shipname":"One Person",
	"addr1":"1 One St",
	"addr2":"Apt #1",
	"city":"Unoville",
	"state":"BC",
	"postcode":"V1B2C3",
	"country":"CA",
	"phone":"+1 604 123 4567",
	"email":"new@one.com",
	"stuff":"one_HC=1, two_HC=2",
	"gift":"no",
	"gift_note":"not a gift"
}'::jsonb, 'one row, physical stuff only');

select is(stork.preship() -> 2 ->> 'stuff', 'one_HC_WRAP=1', 'gift stuff');
