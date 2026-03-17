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
insert into items (id, metaitem_id, sku, name, price_id, weight) values (1, 1, 'one-digi', 'one digital', 0, 0);
insert into items (id, metaitem_id, sku, name, price_id, weight) values (2, 1, 'one-hard', 'one hardcover', 2, 1);
insert into invoices (id, person_id, created, currency, warehouse, shipcost, total, payment, paydate, payinfo, status, shipdate, shipinfo, shipname, addr1, addr2, city, state, postcode, country, phone, gift_note) values (1, 2, '2025-11-11', 'EUR', 'US', 3.5, 20, 20, '2025-11-11', 'one-blah', 'hold', null, null, 'Boo', 'Boo Str 1', null, 'Booville', null, 'boo123', 'BE', '+33445566', null);
insert into lineitems (id, invoice_id, item_id, quantity, price) values (1, 1, 2, 1, 16.5);

select plan(7);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.invoice_update('BadCookieBadCookieBadCookieBadKK', 1, '{"total":9999,"gift_note":"happy day","phone":"+33998877"}'::json);

select is(head, e'303\r\nLocation: /invoice/1'),
	is(body, null)
from storm.invoice_update('StormAdmin1StormAdmin1StormAdmin', 1, '{"total":9999,"gift_note":"happy day","phone":"+33998877"}'::json);

select is(total, 20::numeric),
	is(gift_note, 'happy day'),
	is(phone, '+33998877')
from invoices where id = 1;
