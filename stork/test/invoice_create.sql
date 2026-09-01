-- man, look at all the entries needed just to make an invoice

insert into countries (code, name) values ('US', 'U.S.A.');

insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);

insert into people (id, name) values (1, 'Mr. One');
insert into ats (person_id, email) values (1, 'one@one.com');

alter table invoices alter column id restart with 10;

select plan(5);

select is(count(*)::integer, 0) from invoices;

select is(head, e'303\r\nLocation: /invoice/10'),
	is(body, null, 'redirecting to /invoice/10')
from stork.invoice_create(1);

select is(count(*)::integer, 1) from invoices;

select is(person_id, 1) from invoices where id = 10;

