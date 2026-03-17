insert into people (id, name) values (1, 'Has Photo');
insert into now_profiles (id, public_id, photo) values (1, 'PUBi', true);
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into people (id, name) values (2, 'No Photo');
insert into now_profiles (id, public_id, photo) values (2, 'PUBx', false);
insert into logins (cookie, person_id) values ('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 2);

select plan(6);

select is(code, null, 'no cookie') from mynow.photoset(null);
select is(code, null, 'bad cookie') from mynow.photoset('dddXdddXdddXdddXdddXdddXdddXdddd');
select is(code, 'PUBi', 'ok') from mynow.photoset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
select ok(photo, 'same') from now_profiles where id = 1;
select is(code, 'PUBx', 'ok2') from mynow.photoset('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
select ok(photo, 'updated') from now_profiles where id = 2;

