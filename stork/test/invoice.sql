-- man, look at all the entries needed just to make an invoice

insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);

insert into people (id, name) values (1, 'Mr. One');
insert into ats (person_id, email) values (1, 'one@one.com');

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


insert into invoices
(id, person_id, add2, created, currency, warehouse,
shipcost, total, payment, paydate, payinfo, status, code,
shipdate, shipinfo, shipname, addr1, addr2,
city, state, postcode, country, phone, gift_note)
values
(1, 1, null, '2026-08-01', 'CAD', 'US',
17.41, 77.66, 77.66, '2026-08-02', 'code#abc123', 'done', 'aBcDeFgH',
'2026-08-03', 'RL123456', 'One Person', '1 One St', 'Apt #1',
'Unoville', 'BC', 'V1B2C3', 'CA', '+1 604 123 4567', 'not a gift');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (100, 1, 11, 1, 27.25);
insert into lineitems (id, invoice_id, item_id, quantity, price) values (101, 1, 21, 2, 33);

insert into templates (code, template) values ('stork-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('stork-invoice', '
INVOICE:
id:{{id}}
person_id:{{person_id}}
add2:{{add2}}
created:{{created}}
currency:{{currency}}
warehouse:{{warehouse}}
shipcost:{{shipcost}}
total:{{total}}
payment:{{payment}}
paydate:{{paydate}}
payinfo:{{payinfo}}
status:{{status}}
code:{{code}}
shipdate:{{shipdate}}
shipinfo:{{shipinfo}}
shipname:{{shipname}}
addr1:{{addr1}}
addr2:{{addr2}}
city:{{city}}
state:{{state}}
postcode:{{postcode}}
country:{{country}}
phone:{{phone}}
gift_note:{{gift_note}}
ALSO:
country_name:{{country_name}}
name:{{name}}
email:{{email}}
LINEITEMS:
{{#lineitems}}
id:{{id}}
name:{{name}}
quantity:{{quantity}}
price:{{price}}
{{/lineitems}}
ALLITEMS:
{{#allitems}}
id:{{id}}
name:{{name}}
{{/allitems}}
ALLSTATUSES:
{{#allstatuses}}
.:{{.}}
{{/allstatuses}}
');

select plan(2);

select is(head, null),
	is(body, '<html>
INVOICE:
id:1
person_id:1
add2:
created:2026-08-01
currency:CAD
warehouse:US
shipcost:17.41
total:77.66
payment:77.66
paydate:2026-08-02
payinfo:code#abc123
status:done
code:aBcDeFgH
shipdate:2026-08-03
shipinfo:RL123456
shipname:One Person
addr1:1 One St
addr2:Apt #1
city:Unoville
state:BC
postcode:V1B2C3
country:CA
phone:+1 604 123 4567
gift_note:not a gift
ALSO:
country_name:Canada
name:Mr. One
email:one@one.com
LINEITEMS:
id:100
name:Book One (hardcover)
quantity:1
price:27.25
id:101
name:Book Two (hardcover)
quantity:2
price:33.00
ALLITEMS:
id:10
name:Book One (digital)
id:11
name:Book One (hardcover)
id:12
name:Book One (paperback)
id:20
name:Book Two (digital)
id:21
name:Book Two (hardcover)
id:23
name:Book Two (autographed)
ALLSTATUSES:
.:cart
.:ship
.:wait
.:problem
.:done
</html>')
from stork.invoice(1);

