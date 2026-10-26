insert into people (id, name) values (1, 'Ad Min');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);
insert into admins (person_id, hashpass) values (1, '$2a$10$nEVG6F4T7JU5dmIKwPVeLuHm0WLilRRzxCk4uqk16iLHqDa7LmI3.');
insert into admin_auths (person_id, appcode) values (1, 'stork');

insert into people (id, name) values (2, 'Other Admin');
insert into logins (cookie, person_id) values ('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq', 2);
insert into admins (person_id, hashpass) values (2, '$2a$10$nEVG6F4T7JU5dmIKwPVeLuHm0WLilRRzxCk4uqk16iLHqDa7LmI4.');
insert into admin_auths (person_id, appcode) values (2, 'other');

select plan(5);

select is(stork.auth(null), null, 'no cookie');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz01234'), null, '31 letter not OK');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz012345G'), null, '33 letter not OK');
select is(stork.auth('abcdefghijklmnopqrstuvwxyz012345'), 1, 'yes stork admin');
select is(stork.auth('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'), null, 'admin but not stork admin');

