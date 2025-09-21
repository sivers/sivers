insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('US', 'OR', 'Oregon');
insert into states (country, code, name) values ('US', 'AK', 'Alaska');

insert into people (id, name, city, state, country) values (1, 'Porter', 'Portland', 'OR', 'US');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into people (id, name) values (2, 'Cole');
insert into logins (cookie, person_id) values ('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 2);

insert into templates (code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-whereru', 'Where are you {{name}}?
{{#countries}}<option value="{{code}}"{{selected}}>{{name}}</option>{{/countries}}
city={{city}}
state={{state}}
<script>const states = {{{states}}};</script>');

select plan(8);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.whereru(null);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.whereru('dddXdddXdddXdddXdddXdddXdddXdddd');

select is(head, null),
	is(body, '<html>Where are you Porter?
<option value="GB">United Kingdom</option><option value="US" selected>United States</option>
city=Portland
state=OR
<script>const states = {"GB": [{"code": "ENG", "name": "England", "selected": ""}, {"code": "WLS", "name": "Wales", "selected": ""}], "US": [{"code": "AK", "name": "Alaska", "selected": ""}, {"code": "OR", "name": "Oregon", "selected": " selected"}]};</script></html>')
from mynow.whereru('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

select is(head, null),
	is(body, '<html>Where are you Cole?
<option value="GB">United Kingdom</option><option value="US">United States</option>
city=
state=
<script>const states = {"GB": [{"code": "ENG", "name": "England", "selected": ""}, {"code": "WLS", "name": "Wales", "selected": ""}], "US": [{"code": "AK", "name": "Alaska", "selected": ""}, {"code": "OR", "name": "Oregon", "selected": ""}]};</script></html>')
from mynow.whereru('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

