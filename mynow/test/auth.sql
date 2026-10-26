insert into people (id, name) values (1, 'Yes Now Page');
insert into logins (person_id, cookie) values (1, 'abcdefghijklmnopqrstuvwxyzABCDEF');
insert into now_pages (person_id, long) values (1, 'https://yes.com/now');

insert into people (id, name) values (2, 'No Now Page');
insert into logins (person_id, cookie) values (2, 'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');

select plan(5);

select is(mynow.auth(null), null, 'no cookie');
select is(mynow.auth('abcdefghijklmnopqrstuvwxyzABCDE'), null, '31 letter not OK');
select is(mynow.auth('abcdefghijklmnopqrstuvwxyzABCDEFG'), null, '33 letter not OK');
select is(mynow.auth('abcdefghijklmnopqrstuvwxyzABCDEF'), 1, 'yes has now page');
select is(mynow.auth('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'), null, 'no now page, no auth');

