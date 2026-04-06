insert into people (id, name, lopass) values (1, 'One Person', 'aB3D');
insert into ats (person_id, email, listype) values (1, 'one@one.com', 'all');
insert into ats (person_id, email, listype) values (1, 'old@old.net', null);

select plan(8);

select is(head, e'303\r\nLocation: /contact'),
	is(body, null, 'bad lopass')
from me.list_post(1, 'xxxx', 'all');

select is(head, e'303\r\nLocation: /contact'),
	is(body, null, 'bad listype')
from me.list_post(1, 'aB3D', 'poop');

select is(head, e'303\r\nLocation: /thanks?for=list'),
	is(body, null)
from me.list_post(1, 'aB3D', 'some');

select is(listype, 'none') from ats where email = 'old@old.net';
select is(listype, 'some') from ats where email = 'one@one.com';

