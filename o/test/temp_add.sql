insert into people (id, name) values (1, 'Person A');
insert into ats (email, person_id) values ('a@a.com', 1);
insert into logins (cookie, person_id) values ('abcdefghijklmnopqrstuvwxyz012345', 1);

insert into people (id, name) values (2, 'Person B');
insert into ats (email, person_id) values ('b@b.com', 2);


select plan(12);

select is(r.person_id, 1),
	is(r.name, 'Person A'),
	is(r.email, 'a@a.com'),
	is(length(r.temp), 16)
from o.temp_add(1) r;

-- existing name used instead of new given
select is(r.person_id, 2),
	is(r.name, 'Person B'),
	is(r.email, 'b@b.com'),
	is(length(r.temp), 16)
from o.temp_add('B-man, dude!!', 'b@b.com') r;

-- name and email cleaned for new
select is(r.person_id, null),
	is(r.name, 'New Person C'),
	is(r.email, 'c@c.com'),
	is(length(r.temp), 16)
from o.temp_add('   New   <strong>Person C</strong>   ', e' c \t \r \n @C.COM \r') r;

