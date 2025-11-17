insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (3, 'Cat');
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (3, 'cat@cat.cat');
insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('GB', 'United Kingdom');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('GBP', 'British Pounds', 'select concat(''GBP £'', trim(to_char(AMOUNT, ''999G990D00'')))', 0.748923, '2025-10-10', 2);
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
insert into invoices (id, person_id, created, currency, shipcost, total, payment, paydate, payinfo, status) values (2, 3, '2025-11-12', 'GBP', 0, 11, 11, '2025-11-12', 'two-blah', 'done');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (2, 2, 3, 1, 11);
insert into invoices (id, person_id, created, currency, total, status) values (4, 3, '2025-11-14', 'GBP', 11, 'cart');
insert into lineitems (id, invoice_id, item_id, quantity, price) values (4, 4, 1, 1, 11);
insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-person', '
PERSON:
{{#person}}
id={{id}}
name={{name}}
emails={{emails}}
{{/person}}
INVOICES:
{{#invoices}}
id={{id}}
created={{created}}
status={{status}}
paydate={{paydate}}
currency={{currency}}
total={{total}}
{{#lineitems}}
 line.id={{id}}
 name={{name}}
 quantity={{quantity}}
 price={{price}}
{{/lineitems}}
--
{{/invoices}}
');

select plan(6);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.person('BadCookieBadCookieBadCookieBadKK', 3);

select is(head, e'303\r\nLocation: /'),
	is(body, null)
from storm.person('StormAdmin1StormAdmin1StormAdmin', 999);

select is(head, null),
	is(body, '<html>
PERSON:
id=3
name=Cat
emails=cat@cat.cat
INVOICES:
id=2
created=2025-11-12
status=done
paydate=2025-11-12
currency=GBP
total=11.00
 line.id=2
 name=two digital
 quantity=1
 price=11
--
id=4
created=2025-11-14
status=cart
paydate=
currency=GBP
total=11.00
 line.id=4
 name=one digital
 quantity=1
 price=11
--
</html>')
from storm.person('StormAdmin1StormAdmin1StormAdmin', 3);

