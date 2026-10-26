insert into people (id, name) values (1, 'Ad Min');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);
insert into admins (person_id) values (1);
insert into admin_auths (person_id, appcode) values (1, 'stork');

insert into people (id, name) values (2, 'Other Admin');
insert into logins (cookie, person_id) values ('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq', 2);
insert into admins (person_id) values (2);
insert into admin_auths (person_id, appcode) values (2, 'other');

select plan(5);

select is(stork.auth(null), false, 'no cookie');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz01234'), false, '31 letter not OK');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz012345G'), false, '33 letter not OK');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz012345'), true, 'yes stork admin');
select is(stork.auth('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'), false, 'admin but not stork admin');

