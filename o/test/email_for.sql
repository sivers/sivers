insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id, used) values ('old@a.com', 1, '2000-01-01 01:01:01');
insert into ats (email, person_id) values ('new@a.com', 1);

insert into people (id, name) values (2, 'Person B');
insert into ats (email, person_id, used) values ('old@b.com', 2, null);
insert into ats (email, person_id) values ('new@b.com', 2);

insert into people (id, name) values (3, 'Person C');
insert into ats (email, person_id, listype, used) values ('public@c.com', 3, 'all', '2000-01-01 01:01:01');
insert into ats (email, person_id, listype) values ('private@c.com', 3, 'none'); -- should use older since 'none'

select plan(6);

select is(o.email_for(1), 'new@a.com');
select is(o.email_nonone_for(1), 'new@a.com');
select is(o.email_for(2), 'new@b.com');
select is(o.email_nonone_for(2), 'new@b.com');
select is(o.email_for(3), 'private@c.com');
select is(o.email_nonone_for(3), 'public@c.com');

