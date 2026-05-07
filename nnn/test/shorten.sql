insert into people (id, name) values (1, 'EE');
insert into people (id, name) values (2, 'FF');

insert into now_pages (person_id, long) values (1, 'https://www.ee.com/now/');
insert into now_pages (person_id, long) values (2, 'http://ff.com/now.html');

select plan(4);

select is(short, 'ee.com/now') from now_pages where person_id = 1;
select is(short, 'ff.com/now.html') from now_pages where person_id = 2;

update now_pages set long = 'https://www.newee.net/now.html' where person_id = 1;
update now_pages set long = 'https://www.newff.org/pages/now/' where person_id = 2;

select is(short, 'newee.net/now.html') from now_pages where person_id = 1;
select is(short, 'newff.org/pages/now') from now_pages where person_id = 2;
