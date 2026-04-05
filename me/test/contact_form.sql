insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('US', 'OR', 'Oregon');
insert into states (country, code, name) values ('US', 'AK', 'Alaska');

insert into ips (range, country, state, city) values ('[16843008,16843264)', 'GB', 'ENG', 'Oxford'); -- 1.1.1.1
insert into ips (range, country, state, city) values ('[134744064,134744320)', 'US', 'OR', 'Portland'); -- 8.8.8.8

insert into templates (code, template) values ('me-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('me-contactform', 'Where?
{{#countries}}<option value="{{code}}"{{selected}}>{{name}}</option>{{/countries}}
city={{city}}
state={{state}}
<script>const states = {{{states}}};</script>');

select plan(4);

select is(head, null),
	is(body, '<html>Where?
<option value="GB">United Kingdom</option><option value="US" selected>United States</option>
city=Portland
state=OR
<script>const states = {"GB": [{"code": "ENG", "name": "England", "selected": ""}, {"code": "WLS", "name": "Wales", "selected": ""}], "US": [{"code": "AK", "name": "Alaska", "selected": ""}, {"code": "OR", "name": "Oregon", "selected": " selected"}]};</script></html>')
from me.contact_form('8.8.8.8');

select is(head, null),
	is(body, '<html>Where?
<option value="GB" selected>United Kingdom</option><option value="US">United States</option>
city=Oxford
state=ENG
<script>const states = {"GB": [{"code": "ENG", "name": "England", "selected": " selected"}, {"code": "WLS", "name": "Wales", "selected": ""}], "US": [{"code": "AK", "name": "Alaska", "selected": ""}, {"code": "OR", "name": "Oregon", "selected": ""}]};</script></html>')
from me.contact_form('1.1.1.1');


