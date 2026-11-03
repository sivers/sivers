-- test data copied from o/test/ipcc.sql

insert into countries (code, name) values ('NZ', 'New Zealand');
insert into countries (code, name) values ('AU', 'Australia');
insert into countries (code, name) values ('US', 'U.S.A.');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', now(), $$select concat('USD $', trim(to_char(AMOUNT, '999G990')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('NZD', now(), $$select concat('NZD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'New Zealand Dollars', 1.8);
insert into currencies (code, fxdate, fmt, name, fx) values ('AUD', now(), $$select concat('AUD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Australian Dollars', 1.6);

insert into ips (range, country) values ('[33554432,33751040)', 'NZ');
insert into ips (range, country) values ('[235012096,235012864)', 'AU');

insert into country_currency (country, currency) values ('NZ', 'NZD');
insert into country_currency (country, currency) values ('AU', 'AUD');

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

select plan(5);

select is(head, e'Set-Cookie: country=NZ; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nSet-Cookie: currency=NZD; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nSet-Cookie: cart=11-1; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800', 'clean cart')
from store.valid8('', '', '11-1,22-1', '2.0.0.2'); 

select is(head, e'Set-Cookie: country=AU; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nSet-Cookie: currency=AUD; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800', 'replace bad country')
from store.valid8('XX', 'XXX', '', '14.2.2.4'); 

select is(head, e'Set-Cookie: country=US; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nSet-Cookie: currency=USD; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800', 'empty sets no cart')
from store.valid8('', '', '', '123.123.123.123'); 

select is(head, e'Set-Cookie: cart=20-1; Path=/store; Secure; HttpOnly; SameSite=Strict; Max-Age=604800', 'country and currency OK, just fix cart')
from store.valid8('AU', 'AUD', '99-9,20-9', '123.123.123.123'); 

select is(head, null, 'everything OK, no cookies added')
from store.valid8('AU', 'AUD', '11-1', '123.123.123.123'); 


