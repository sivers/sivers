-- should views go here or somewhere else?
-- it's very omni, used in a few places

insert into countries (code, name) values ('US', 'U.S.A.');
insert into people (id, name, company, city, state, country) values (1, 'Dude', 'Big Inc', 'Venice', 'CA', 'US');
insert into ats (email, person_id) values ('dude@du.de', 1);
insert into ats (email, person_id) values ('dude@well.com', 1);

select plan(8);
select is(id, 1),
	is(name, 'Dude'),
	is(company, 'Big Inc'),
	is(email_count, 0),
	is(city, 'Venice'),
	is(state, 'CA'),
	is(country, 'US'),
	is(emails, 'dude@du.de,dude@well.com')
from o.view_people where id = 1;
