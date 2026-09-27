insert into countries (code, name) values ('US', 'U.S.A.');
insert into countries (code, name) values ('CA', 'Canada');
insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into configs (k, v) values ('sig', 'signing off');

insert into warehouses (country) values ('US');
insert into postzones (warehouse, country, zone) values ('US', 'US', 1);
insert into postzones (warehouse, country, zone) values ('US', 'CA', 1);
insert into postrates (zone, books, currency, amount) values (1, 1, 'USD', 8.86);

insert into prices (id, base, info, usd) values (1000, 'USD', 'free', 0);
insert into prices (id, base, info, usd) values (1001, 'USD', 'metaitem', 15);
insert into prices (id, base, info, usd) values (1002, 'USD', 'hardcover', 4);
insert into prices (id, base, info, usd) values (1004, 'USD', 'signed', 6);
insert into metaitems (id, name, price_id) values (1, 'Book One', 1001);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (10, 1, 'one', 'Book One (digital)', 1000, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (11, 1, 'one_HC', 'Book One (hardcover)', 1002, 1);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (13, 1, 'one_HCS', 'Book One (autographed)', 1004, 1);

insert into people (id, name, greeting) values (1, 'Mr. One', 'Your Highness');
insert into ats (person_id, email) values (1, 'one@one.com');
select setval('emails_id_seq', 1, false);

insert into invoices (id, person_id, status, warehouse, country, shipname, addr1, addr2, city, state, postcode, phone, shipinfo)
values (1, 1, 'done', 'US', 'US', 'One Person', '1 One St', 'Apt #1', 'Unoville', 'NC', '12345', '+1 604 123 4567', 'RL123456');

select plan(34);

select throws_ok('select stork.postship_email(999)', 'P0001', 'not found', 'missing invoice');
select throws_ok('select stork.postship_email(null)', 'P0001', 'not found', 'null invoice');
select throws_ok('select stork.postship_email(1)', 'P0001', 'not found', 'empty invoice');
insert into lineitems (id, invoice_id, item_id) values (100, 1, 10);
select throws_ok('select stork.postship_email(1)', 'P0001', 'not found', 'digital-only invoice');
select is(count(*)::integer, 0, 'rejected invoices create no emails') from emails;

insert into lineitems (id, invoice_id, item_id) values (101, 1, 11);
select is(stork.postship_email(1), 1, 'returns inserted email ID');
select is(person_id, 1),
	is(created_by, 0, 'automated sender'),
	is(their_email, 'one@one.com'),
	is(outgoing, null::boolean, 'queued for sending'),
	is(subject, 'Your book began its journey', 'digital item does not make subject plural'),
	is(body, 'Hi Your Highness -

Your book began its journey from North Carolina to:

One Person
1 One St
Apt #1
Unoville, NC 12345
phone: +1 604 123 4567

You should receive:
1 × Book One (hardcover)

Track the package here:
https://tools.usps.com/go/TrackConfirmAction.action?tLabels=RL123456
(It might not show activity until tomorrow.)

REMINDER: You get all digital formats like audiobook and e-book included forever! Just go to:

https://sivers.com/

... and log in with this email address (one@one.com) any time on any device.  This is order# 1.

--
signing off', 'complete US email, without digital contents or autograph note')
from emails where id = 1;

update lineitems set quantity = 2 where id = 101;
update invoices set shipinfo = '1Z123456' where id = 1;
select is(stork.postship_email(1), 2);
select is(subject, 'Your books began their journey', 'quantity alone makes the subject plural'),
	is(strpos(body, e'2 × Book One (hardcover)\n') > 0, true, 'contents show quantity'),
	is(strpos(body, 'https://wwwapps.ups.com/WebTracking/processRequest?tracknum=1Z123456') > 0, true, '1Z tracking selects UPS for US destination')
from emails where id = 2;

insert into lineitems (id, invoice_id, item_id) values (102, 1, 13);
update invoices set country = 'CA', state = 'BC', postcode = 'V1B2C3' where id = 1;
select is(stork.postship_email(1), 3);
select is(strpos(body, e'Unoville\nBC\nV1B2C3\nCanada\nphone: +1 604 123 4567') > 0, true, 'international address includes state, postcode, and country'),
	is(strpos(body, e'1 × Book One (autographed)\n') > 0, true, 'autographed item included'),
	is(strpos(body, 'NOTE: I signed the autographed book in the last few pages at the END of the book.') > 0, true, 'autograph note included'),
	is(strpos(body, 'https://wwwapps.ups.com/WebTracking/processRequest?tracknum=1Z123456') > 0, true, 'UPS takes precedence for international destination too')
from emails where id = 3;

update invoices set shipinfo = 'RL123NL456', addr2 = null, state = null, postcode = null, phone = null where id = 1;
select is(stork.postship_email(1), 4);
select is(strpos(body, e'One Person\n1 One St\nUnoville\nCanada\n\nYou should receive:') > 0, true, 'missing optional international address fields are omitted'),
	is(strpos(body, 'https://www.goglobalpost.com/track-detail/?t=RL123NL456') > 0, true, 'international non-UPS tracking selects GlobalPost')
from emails where id = 4;

update invoices set country = 'US', shipinfo = null, shipname = null, addr1 = null, city = null where id = 1;
select is(stork.postship_email(1), 5);
select is(strpos(body, 'You should receive:') > 0, true, 'null address fields do not erase shipment details'),
	is(strpos(body, 'Track the package here:'), 0, 'null tracking omits tracking section'),
	is(strpos(body, 'It might not show activity until tomorrow.'), 0, 'no tracking disclaimer without tracking')
from emails where id = 5;

update invoices set shipinfo = '' where id = 1;
select is(stork.postship_email(1), 6);
select is(strpos(body, 'Track the package here:'), 0, 'empty tracking also omits tracking section')
from emails where id = 6;

delete from ats where person_id = 1;
select is(stork.postship_email(1), null::integer, 'no recipient email address returns null');
select is(count(*)::integer, 6, 'no email inserted without recipient address') from emails;

-- Regression: a missing country must not silently erase the shipment details.
insert into ats (person_id, email) values (1, 'one@one.com');
update invoices set country = null where id = 1;
select is(stork.postship_email(1), 7);
select is(strpos(body, 'You should receive:') > 0, true, 'null country does not erase shipment details')
from emails where id = 7;

