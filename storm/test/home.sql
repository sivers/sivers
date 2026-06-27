insert into currencies (code, fxdate, fmt, name, fx) values ('USD', '2025-12-31', $$select concat('USD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'US Dollars', 1);
insert into currencies (code, fxdate, fmt, name, fx) values ('CAD', '2025-12-31', $$select concat('CAD $', trim(to_char(AMOUNT, '999G990D00')))$$, 'Canadian Dollars', 1.3);
insert into currencies (code, fxdate, fmt, name, fx) values ('EUR', '2025-12-31', $$select concat(trim(to_char(AMOUNT, '999G990D00')), ' € (EUR)')$$, 'Euros', 0.8);

insert into people (id, name) values (1, 'One');
insert into people (id, name) values (2, 'Two');
insert into people (id, name) values (3, 'Three');
insert into people (id, name) values (4, 'Four');
insert into people (id, name) values (5, 'Five');
insert into people (id, name) values (6, 'Six');

insert into invoices (id, person_id, currency, total, paydate, status) values (1, 6, 'EUR', 60.0, '2026-06-06', 'done');
insert into invoices (id, person_id, currency, total, paydate, status) values (2, 5, 'CAD', 50.1, '2026-06-07', 'done');
insert into invoices (id, person_id, currency, total, paydate, status) values (3, 4, 'USD', 40.2, '2026-06-08', 'wait');
insert into invoices (id, person_id, currency, total, paydate, status) values (4, 3, 'EUR', 30.3, '2026-06-09', 'problem');
insert into invoices (id, person_id, currency, total, paydate, status) values (5, 2, 'CAD', 20.4, '2026-06-10', 'ship');
insert into invoices (id, person_id, currency, total, paydate, status) values (6, 1, 'USD', 10.5, '2026-06-11', 'ship');
insert into invoices (id, person_id, currency, total, paydate, status) values (7, 4, 'USD', 11.7, '2026-06-12', 'wait');
insert into invoices (id, person_id, currency, total, paydate, status) values (8, 5, 'CAD', 70.8, '2026-06-13', 'done');

insert into templates (code, template) values ('storm-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('storm-home', '
{{#problem}}
<h1>problem</h1>
<table>
{{#problem}}
<tr><td>{{id}}</td><td>{{name}}</td><td>{{paydate}}</td><td>{{show_money}}</td></tr>
{{/problem}}
</table>
{{/problem}}
{{#ship}}
<h1>ship</h1>
<table>
{{#ship}}
<tr><td>{{id}}</td><td>{{name}}</td><td>{{paydate}}</td><td>{{show_money}}</td></tr>
{{/ship}}
</table>
{{/ship}}
{{#wait}}
<h1>wait</h1>
<table>
{{#wait}}
<tr><td>{{id}}</td><td>{{name}}</td><td>{{paydate}}</td><td>{{show_money}}</td></tr>
{{/wait}}
</table>
{{/wait}}
{{#done}}
<h1>done</h1>
<table>
{{#done}}
<tr><td>{{id}}</td><td>{{name}}</td><td>{{paydate}}</td><td>{{show_money}}</td></tr>
{{/done}}
</table>
{{/done}}
');

select plan(4);

select is(head, null),
	is(body, '<html>
<h1>problem</h1>
<table>
<tr><td>4</td><td>Three</td><td>2026-06-09</td><td>30.30 € (EUR)</td></tr>
</table>
<h1>ship</h1>
<table>
<tr><td>5</td><td>Two</td><td>2026-06-10</td><td>CAD $20.40</td></tr>
<tr><td>6</td><td>One</td><td>2026-06-11</td><td>USD $10.50</td></tr>
</table>
<h1>wait</h1>
<table>
<tr><td>3</td><td>Four</td><td>2026-06-08</td><td>USD $40.20</td></tr>
<tr><td>7</td><td>Four</td><td>2026-06-12</td><td>USD $11.70</td></tr>
</table>
<h1>done</h1>
<table>
<tr><td>1</td><td>Six</td><td>2026-06-06</td><td>60.00 € (EUR)</td></tr>
<tr><td>2</td><td>Five</td><td>2026-06-07</td><td>CAD $50.10</td></tr>
<tr><td>8</td><td>Five</td><td>2026-06-13</td><td>CAD $70.80</td></tr>
</table>
</html>')
from storm.home();

update invoices set status = 'done' where status = 'wait';
select is(head, null, 'categories hide when empty'),
	is(body, '<html>
<h1>problem</h1>
<table>
<tr><td>4</td><td>Three</td><td>2026-06-09</td><td>30.30 € (EUR)</td></tr>
</table>
<h1>ship</h1>
<table>
<tr><td>5</td><td>Two</td><td>2026-06-10</td><td>CAD $20.40</td></tr>
<tr><td>6</td><td>One</td><td>2026-06-11</td><td>USD $10.50</td></tr>
</table>
<h1>done</h1>
<table>
<tr><td>1</td><td>Six</td><td>2026-06-06</td><td>60.00 € (EUR)</td></tr>
<tr><td>2</td><td>Five</td><td>2026-06-07</td><td>CAD $50.10</td></tr>
<tr><td>3</td><td>Four</td><td>2026-06-08</td><td>USD $40.20</td></tr>
<tr><td>7</td><td>Four</td><td>2026-06-12</td><td>USD $11.70</td></tr>
<tr><td>8</td><td>Five</td><td>2026-06-13</td><td>CAD $70.80</td></tr>
</table>
</html>')
from storm.home();

