insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into people (id, name) values (1, 'Mr. One');

insert into invoices (id, person_id, status) values (123, 1, 'ship');
insert into invoices (id, person_id, status) values (124, 1, 'ship');
insert into invoices (id, person_id, status, shipinfo, shipdate) values (125, 1, 'done', 'original', '2026-08-01');

insert into templates (code, template) values ('stork-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('stork-postship2', '{{#shipments}}
{{invoice_id}}={{{shipinfo}}}
{{/shipments}}');

select plan(8);

select is(head, null),
	is(body, '<html>123=abcdefgh
124=abcdefgh
125=stuvwxyz
</html>', 'preview skips header, parses id-id, quoted or not')
from stork.postship2(e'invoice_ids,shipinfo\r\n"123-124","abcdefgh"\r\n125,stuvwxyz\r\n', true);

select is(count(*)::integer, 2, 'preview did not update')
from invoices where status = 'ship';

select is(head, e'303\r\nLocation: /'),
	is(body, null, 'redirect after confirmation')
from stork.postship2(e'"123-124","abcdefgh"\r\n125,stuvwxyz\r\n', false);

select is(count(*)::integer, 2, 'both invoices updated, but not the one already done')
from invoices
where id in (123, 124)
and status = 'done'
and shipdate = current_date
and shipinfo = 'abcdefgh';

select is(shipinfo, 'original', 'completed invoice unchanged'),
	is(shipdate, '2026-08-01'::date)
from invoices where id = 125;

