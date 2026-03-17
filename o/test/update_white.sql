insert into countries(code, name) values ('US', 'U.S.A.');
insert into people (id, name, greeting, city, state, country, phone, notes)  values (1, 'Jeff Lebowski', 'Dude', 'Venice', 'CA', 'US', '(213)555-1212', 'abides');

select plan(3);

do $$ begin
perform * from o.update_white('people', 1,
	'{"id":999,"phone":"2135551212","city":"", "drug":"weed","notes":"ignore"}'::json,
	'{phone, city, state}',
	'{city}');
end $$;

select is(phone, '2135551212', 'updated'),
	is(city, null, 'null instead of empty'),
	is(notes, 'abides', 'not whitelisted')
from people where id = 1;

