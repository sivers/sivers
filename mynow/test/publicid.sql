insert into people (id, name) values (1, 'al');
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);
insert into now_profiles (id, public_id) values (1, 'PUBa');

select plan(1);

select is('PUBa', mynow.publicid('abcdefghijklmnopqrstuvwxyz012345'));
