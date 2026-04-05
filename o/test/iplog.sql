insert into people(id, name) values (1, 'Me');

insert into countries (code, name) values ('NZ', 'New Zealand');

insert into stats (person_id, statkey, statvalue) values (1, 'dummy', 'for testing');

insert into ips (range, country, state, city) values ('[33554432,33751040)', 'NZ', 'WLG', 'Paekakariki'); -- 2.0.0.2

select plan(6);

select o.iplog(1, '2.0.0.2');
select is(count(*)::integer, 5, 'first time insert') from stats where person_id = 1;

select o.iplog(1, '2.0.0.2');
select is(count(*)::integer, 5, 'second time nothing') from stats where person_id = 1;

select is(statvalue, '2.0.0.2')
from stats where person_id = 1 and statkey = 'ip';

select is(statvalue, 'NZ')
from stats where person_id = 1 and statkey = 'country';

select is(statvalue, 'WLG')
from stats where person_id = 1 and statkey = 'state';

select is(statvalue, 'Paekakariki')
from stats where person_id = 1 and statkey = 'city';

