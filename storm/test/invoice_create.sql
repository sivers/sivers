insert into people (id, name) values (1, 'admin');
insert into admin_auths (person_id, appcode) values (1, 'storm');
insert into logins (cookie, person_id) values ('StormAdmin1StormAdmin1StormAdmin', 1);
insert into people (id, name) values (2, 'Boo');
insert into ats (person_id, email) values (1, 'at@at.at');
insert into ats (person_id, email) values (2, 'boo@boo.boo');
insert into currencies (code, name, fmt, fx, fxdate, round2) values ('USD', 'US Dollars', 'select concat(''USD $'', trim(to_char(AMOUNT, ''999G990'')))', 1, '2025-10-10', 2);

alter table invoices alter column id restart with 1;

select plan(6);

select is(head, e'303\r\nLocation: /login'),
	is(body, null)
from storm.invoice_create('BadCookieBadCookieBadCookieBadKK', 2);

select is(head, e'303\r\nLocation: /invoice/1'),
	is(body, null)
from storm.invoice_create('StormAdmin1StormAdmin1StormAdmin', 2);

select is(head, e'303\r\nLocation: /invoice/2'),
	is(body, null, 'doesn’t care if one is open already')
from storm.invoice_create('StormAdmin1StormAdmin1StormAdmin', 2);

