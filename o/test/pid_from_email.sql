insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id) values ('a@a.com', 1);

insert into people (id, name) values (2, 'Person B');
insert into ats (email, person_id) values ('b@b.com', 2);

select plan(3);

select is(o.pid_from_email(' <B@B.COM> '), 2);
select is(o.pid_from_email(' a@a.COM '), 1);
select is(o.pid_from_email('a@a.no'), null);

