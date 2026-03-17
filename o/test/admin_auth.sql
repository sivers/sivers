insert into people (id, name) values (1, 'admin1');
insert into people (id, name) values (2, 'admin2');

insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (1, 'alt@one.one');
insert into ats (person_id, email) values (2, 'two@two.two');

insert into admins (person_id) values (1);
insert into admins (person_id) values (2);

insert into admin_auths (person_id, appcode) values (1, 'app1');
insert into admin_auths (person_id, appcode) values (1, 'app2');
insert into admin_auths (person_id, appcode) values (2, 'app2');

select plan(10);

select is(admin_auth, null, 'password not set yet')
from o.admin_auth('one@one.one', 'one?password!', 'app1');

select is(admin_auth, null, 'password not set yet')
from o.admin_auth('two@two.two', 'two!password?', 'app2');

select o.admin_pass_set(1, 'one?password!');
select o.admin_pass_set(2, 'two!password?');

select is(admin_auth, 1, 'password set now')
from o.admin_auth('one@one.one', 'one?password!', 'app1');

select is(admin_auth, 2, 'password set now')
from o.admin_auth('two@two.two', 'two!password?', 'app2');

select isnt(hashpass, 'one?password!', 'no plaintext pass')
from admins where person_id = 1;

select is(admin_auth, 1, 'alt email works')
from o.admin_auth('alt@one.one', 'one?password!', 'app2');

select is(admin_auth, null, 'app limiting')
from o.admin_auth('two@two.two', 'two!password?', 'app1');

select is(admin_auth, null, 'non-existent app')
from o.admin_auth('two@two.two', 'two!password?', 'app9');

select is(admin_auth, null, 'non-existent email')
from o.admin_auth('xxx@xxx.xxx', 'two!password?', 'app2');

select is(admin_auth, null, 'case-sensitive password')
from o.admin_auth('one@one.one', 'One?Password!', 'app1');

