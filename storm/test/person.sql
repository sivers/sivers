insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'U.S. Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

insert into people (id, name) values (1, 'Person One');
insert into people (id, name) values (2, 'Person Two');
insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (2, 'two@two.com');
insert into ats (person_id, email) values (2, 'two@two.org');

insert into prices (id, cad, eur) values (1001, 21.5, 14);
insert into prices (id, cad, eur) values (1002, 5.75, 3.75);
insert into metaitems (id, name, price_id) values (1, 'm-one', 1001);
insert into metaitems (id, name, price_id) values (2, 'm-two', 1001);
insert into items (id, metaitem_id, sku, name, price_id) values (1, 1, 'i1', 'i-one', 1002);
insert into items (id, metaitem_id, sku, name, price_id) values (2, 2, 'i2', 'i-two', 1002);

insert into invoices (id, person_id, currency, total, paydate, status) values (1, 1, 'EUR', 39.25, '2026-06-06', 'done');
insert into lineitems (invoice_id, item_id, quantity, price) values (1, 1, 2, 21.50);
insert into lineitems (invoice_id, item_id, quantity, price) values (1, 2, 1, 17.75);
insert into invoices (id, person_id, currency, total, status) values (2, 2, 'CAD', 44.50, 'cart');
insert into lineitems (invoice_id, item_id, quantity, price) values (2, 2, 4, 44.50);
insert into invoices (id, person_id, currency, total, paydate, status) values (3, 1, 'EUR', 5.75, '2026-06-07', 'wait');
insert into lineitems (invoice_id, item_id, quantity, price) values (3, 1, 1, 5.75);

insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-person', 'id:{{id}}
name:{{name}}
emails:{{emails}}
invoices:
{{#invoices}}
 id:{{id}}
 status:{{status}}
 paydate:{{paydate}}
 show_total:{{show_total}}
 lineitems:
{{#lineitems}}
  name:{{name}}
  quantity:{{quantity}}
  show_price:{{show_price}}
{{/lineitems}}
{{/invoices}}
');

select plan(8);

select is(head, e'303\r\nLocation: /'),
	is(body, null, '404 redirects')
from storm.person(99);

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'null redirects')
from storm.person(null);

select is(head, null, 'person 1'),
	is(body, '<html>id:1
name:Person One
emails:one@one.one
invoices:
 id:3
 status:wait
 paydate:2026-06-07
 show_total:3.75 € (EUR)
 lineitems:
  name:i-one
  quantity:1
  show_price:3.75 € (EUR)
 id:1
 status:done
 paydate:2026-06-06
 show_total:35.50 € (EUR)
 lineitems:
  name:i-one
  quantity:1
  show_price:17.75 € (EUR)
  name:i-two
  quantity:1
  show_price:17.75 € (EUR)
</html>')
from storm.person(1);

select is(head, null, 'person 2'),
	is(body, '<html>id:2
name:Person Two
emails:two@two.com,two@two.org
invoices:
 id:2
 status:cart
 paydate:
 show_total:CAD $27.25
 lineitems:
  name:i-two
  quantity:1
  show_price:CAD $27.25
</html>')
from storm.person(2);

