insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

insert into people (id, name) values (1, 'Ally Ant');
insert into people (id, name) values (2, 'Bobby Brant');
insert into people (id, name) values (3, 'Cally Cobby');
insert into ats (person_id, email) values (1, 'ant@eater.co');
insert into ats (person_id, email) values (2, 'robert@br.uh');
insert into ats (person_id, email) values (3, 'cally@cobby.net');
insert into ats (person_id, email) values (3, 'calungus@ugh.xyz');

insert into invoices (id, person_id, currency, total, paydate, status) values (1, 1, 'EUR', 60.0, '2026-06-06', 'done');
insert into invoices (id, person_id, currency, total, paydate, status) values (2, 2, 'CAD', 50.1, '2026-06-07', 'cart');
insert into invoices (id, person_id, currency, total, paydate, status) values (3, 3, 'USD', 40.2, '2026-06-08', 'wait');

insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-search', '
<form></form>
{{#found}}
<h1>found</h1>
<table>
{{#found}}
<tr><td>{{id}}</td><td>{{name}}</td><td>{{emails}}</td></tr>
{{/found}}
</table>
{{/found}}
');

select plan(7);

select is(head, null, 'head always null'),
	is(body, '<html>
<form></form>
</html>')
from storm.search('');

select is(body, '<html>
<form></form>
</html>', 'null input ok')
from storm.search(null);

select is(body, '<html>
<form></form>
</html>', '2 = too short')
from storm.search('an');

select is(body, '<html>
<form></form>
<h1>found</h1>
<table>
<tr><td>3</td><td>Cally Cobby</td><td>calungus@ugh.xyz</td></tr>
</table>
</html>', 'xyz found email')
from storm.search('xyz');


select is(body, '<html>
<form></form>
<h1>found</h1>
<table>
<tr><td>1</td><td>Ally Ant</td><td>ant@eater.co</td></tr>
<tr><td>2</td><td>Bobby Brant</td><td>robert@br.uh</td></tr>
</table>
</html>', 'ant found Ant and Brant')
from storm.search('ant');


select is(body, '<html>
<form></form>
<h1>found</h1>
<table>
<tr><td>1</td><td>Ally Ant</td><td>ant@eater.co</td></tr>
<tr><td>3</td><td>Cally Cobby</td><td>cally@cobby.net,calungus@ugh.xyz</td></tr>
</table>
</html>', 'Ally found Ally and Cally')
from storm.search('Ally');

