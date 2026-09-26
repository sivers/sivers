--- SAME TEST DATA as preship.sql (and preship_see.sql)

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


select plan(4);

select is(head, e'Content-Type: text/csv; charset=utf-8\r\nContent-Disposition: attachment; filename="preship.csv"', 'empty csv head'),
	is(body, e'howmany,item_id,sku,quantity,invid,paydate,shipcost,person_id,shipname,addr1,addr2,city,state,postcode,country,phone,email,stuff,gift,gift_note\r\n', 'empty csv body')
from stork.preship_csv();

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

select is(head, e'Content-Type: text/csv; charset=utf-8\r\nContent-Disposition: attachment; filename="preship.csv"', 'full csv head'),
	is(body, e'howmany,item_id,sku,quantity,invid,paydate,shipcost,person_id,shipname,addr1,addr2,city,state,postcode,country,phone,email,stuff,gift,gift_note\r
"2","11","one_HC","1","1","2026-08-02","17.41","1","One Person","1 One St","Apt #1","Unoville","BC","V1B2C3","CA","+1 604 123 4567","new@one.com","one_HC=1, two_HC=2","no","not a gift"\r
"2","21","two_HC","2","1","2026-08-02","17.41","1","One Person","1 One St","Apt #1","Unoville","BC","V1B2C3","CA","+1 604 123 4567","new@one.com","one_HC=1, two_HC=2","no","not a gift"\r
"2","14","one_HC_WRAP","1","2","2026-08-03","11.52","1","Gift Recipient","2 Two St",,"Unoville","BC","V1B2C3","CA",,"new@one.com","one_HC_WRAP=1","yes","Happy birthday!"\r
"1","11","one_HC","2","3","2026-08-04","14.47","2","Two Person","3 Three St",,"Unoville","BC","V1B2C3","CA",,"two@two.com","one_HC=2","no",\r
', 'full csv body')
from stork.preship_csv();

