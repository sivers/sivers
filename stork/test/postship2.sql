insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');
insert into configs (k, v) values ('sig', 'signing off');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);

insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'US', 1);
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);
insert into people (id, name) values (0, 'robot');
insert into people (id, name) values (1, 'Mr. One');
insert into ats (person_id, email) values (1, 'one@one.com');

insert into prices (id, base, info, usd) values (1000, 'USD', 'free', 0);
insert into prices (id, base, info, usd) values (1001, 'USD', 'metaitem', 15);
insert into prices (id, base, info, usd) values (1002, 'USD', 'hardcover', 4);
insert into prices (id, base, info, usd) values (1004, 'USD', 'signed', 6);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (13, 1, 'one_HCS', 'Book One (autographed)', 1004, 1);

insert into invoices (id, person_id, status, warehouse, country, shipname, addr1, addr2, city, state, postcode, phone)
values (123, 1, 'ship', 'US', 'US', 'One Person', '1 One St', 'Apt #1', 'Unoville', 'NC', '12345', '+1 604 123 4567');
insert into invoices (id, person_id, status, warehouse, country, shipname, addr1, addr2, city, state, postcode, phone)
values (124, 1, 'ship', 'US', 'US', 'One Person', '1 One St', 'Apt #1', 'Unoville', 'NC', '12345', '+1 604 123 4567');
insert into invoices (id, person_id, status, shipinfo, shipdate) values (125, 1, 'done', 'original', '2026-08-01');
insert into lineitems (id, invoice_id, item_id) values (100, 123, 11);
insert into lineitems (id, invoice_id, item_id) values (101, 124, 13);
insert into lineitems (id, invoice_id, item_id) values (102, 125, 11);

insert into templates (code, template) values ('stork-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('stork-postship2', '{{#shipments}}
{{invoice_id}}={{{shipinfo}}}
{{/shipments}}');

select plan(10);

select is(head, null),
	is(body, '<html>123=abcdefgh
124=abcdefgh
125=stuvwxyz
</html>', 'preview skips header, parses id-id, quoted or not')
from stork.postship2(e'invoice_ids,shipinfo\r\n"123-124","abcdefgh"\r\n125,stuvwxyz\r\n', true);

select is(count(*)::integer, 2, 'preview did not update')
from invoices where status = 'ship';

select is(count(*)::integer, 0, 'no emails created') from emails;

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'redirect after confirmation')
from stork.postship2(e'"123-124","abcdefgh"\r\n125,stuvwxyz\r\n', false);

select is(count(*)::integer, 3, '3 emails created. Done invoice re-emailed.') from emails;

select is(count(*)::integer, 2, 'both invoices updated, but not the one already done')
from invoices
where id in (123, 124)
and status = 'done'
and shipdate = current_date
and shipinfo = 'abcdefgh';

select is(shipinfo, 'original', 'completed invoice unchanged'),
	is(shipdate, '2026-08-01'::date)
from invoices where id = 125;

