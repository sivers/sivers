insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (2, 'Boo');
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (2, 'boo@boo.boo');
insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('BE', 'Belgium');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('EUR', 'Euros', 'select concat(trim(to_char(AMOUNT, ''999G990D00'')), '' € (EUR)'')', 0.860704, '2025-10-10', 2);
insert into warehouses (country, address) values ('US', '123 Warehouse Street');
insert into prices (id, base, info, usd, cad, eur, gbp) values (0, 'USD', 'free', 0, 0, 0, 0);
insert into prices (id, base, info, usd, cad, eur, gbp) values (1, 'USD', 'meta', 15, 21, 13, 11);
insert into prices (id, base, info, usd, cad, eur, gbp) values (2, 'USD', 'hard', 4, 5, 3.5, 3);
insert into metaitems (id, name, price_id) values (1, 'one', 1);
insert into metaitems (id, name, price_id) values (2, 'two', 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (1, 1, 'one-digi', 'one digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (2, 1, 'one-hard', 'one hardcover', 2, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (3, 2, 'two-digi', 'two digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (4, 2, 'two-hard', 'two hardcover', 2, 1);
insert into invoices (id, person_id, created, currency, warehouse, shipcost, total, payment, paydate, payinfo, status, shipdate, shipinfo, shipname, addr1, addr2, city, state, postcode, country, phone, gift_note) values (1, 2, '2025-11-11', 'EUR', 'US', 3.5, 20, 20, '2025-11-11', 'one-blah', 'done', '2025-11-12', 'tracking', 'Boo', 'Boo Str 1', 'apt 3', 'Booville', 'Boo', 'boo123', 'BE', '+33445566', 'gift note');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (1, 1, 1, 1, 13);
insert into lineitems (id, invoice_id, item_id, quantity, price) values (2, 1, 2, 1, 3.5);
insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-invoice', '
INVOICE
{{#invoice}}
id={{id}}
person_id={{person_id}}
add2={{add2}}
created={{created}}
currency={{currency}}
warehouse={{warehouse}}
shipcost={{shipcost}}
total={{total}}
payment={{payment}}
paydate={{paydate}}
payinfo={{payinfo}}
status={{status}}
shipdate={{shipdate}}
shipinfo={{shipinfo}}
shipname={{shipname}}
addr1={{addr1}}
addr2={{addr2}}
city={{city}}
state={{state}}
postcode={{postcode}}
country={{country}}
phone={{phone}}
gift_note={{gift_note}}
name={{name}}
{{/invoice}}
LINEITEMS
{{#lineitems}}
id={{id}}
item_id={{item_id}}
quantity={{quantity}}
price={{price}}
name={{name}}
{{/lineitems}}
');

select plan(4);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.invoice('BadCookieBadCookieBadCookieBadKK', 1);

select is(head, null),
	is(body, '<html>
INVOICE
id=1
person_id=2
add2=
created=2025-11-11
currency=EUR
warehouse=US
shipcost=3.5
total=20
payment=20
paydate=2025-11-11
payinfo=one-blah
status=done
shipdate=2025-11-12
shipinfo=tracking
shipname=Boo
addr1=Boo Str 1
addr2=apt 3
city=Booville
state=Boo
postcode=boo123
country=BE
phone=+33445566
gift_note=gift note
name=Boo
LINEITEMS
id=1
item_id=1
quantity=1
price=13
name=one digital
id=2
item_id=2
quantity=1
price=3.5
name=one hardcover
</html>')
from storm.invoice('StormAdmin1StormAdmin1StormAdmin', 1);

