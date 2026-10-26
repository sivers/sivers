insert into people (id, name) values (123, 'Customer Name');
insert into temps (person_id, temp) values (123, 'aBcDeFgHiJkLmNoP');

select plan(4);
select is(head, e'303\r\nLocation: https://sivers.com/e?t=aBcDeFgHiJkLmNoP'),
	is(body, null, 'login as customer')
from stork.person_login(123);

select is(head, e'303\r\nLocation: https://sivers.com/e?t=aBcDeFgHiJkLmNoP', 'can run multiple times')
from stork.person_login(123);

delete from temps;

select matches(head, 'sivers.com/e\?t=\S{16}', 'creates new code')
from stork.person_login(123);
