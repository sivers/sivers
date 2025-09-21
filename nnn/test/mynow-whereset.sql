insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into countries (code, name) values ('SG','Singapore');

insert into people (id, name, city, state, country) values (1, 'Porter', 'Portland', 'OR', 'US');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into people (id, name) values (2, 'Cole');
insert into logins (cookie, person_id) values ('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 2);

select plan(32);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.whereset(null, 'My City', 'My State', 'GB');

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.whereset('dddXdddXdddXdddXdddXdddXdddXdddd', 'My City', 'My State', 'GB');

select is(head, e'303\r\nLocation: /?again'),
	is(body, null, 'no country')
from mynow.whereset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'My City', 'My State', null);

select is(head, e'303\r\nLocation: /?again'),
	is(body, null, 'empty country')
from mynow.whereset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'My City', 'My State', '');

select is(head, e'303\r\nLocation: /?err'),
	is(body, null, 'bad country')
from mynow.whereset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'My City', 'My State', 'ZZ');

select is(country, 'US', 'unchanged by bad calls') from people where id = 1;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'Good Boy')
from mynow.whereset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'My City', 'My State', 'GB');

select is(name, 'Porter'),
	is(city, 'My City'),
	is(state, 'My State'),
	is(country, 'GB')
from people where id = 1;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'city state empty string becomes null')
from mynow.whereset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', ' ', '  ', 'GB');

select is(city, null), is(state, null) from people where id = 1;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'can set country leaving city state blank')
from mynow.whereset('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', '', '', 'US');

select is(name, 'Cole'),
	is(city, null),
	is(state, null),
	is(country, 'US')
from people where id = 2;

select is(head, e'303\r\nLocation: /urls'),
	is(body, null, 'set city not state')
from mynow.whereset('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 'Singapore', '', 'SG');

select is(city, 'Singapore'),
	is(state, null),
	is(country, 'SG')
from people where id = 2;

