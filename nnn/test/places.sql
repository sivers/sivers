insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into countries (code, name) values ('SG','Singapore');

insert into states (country, code, name) values ('US', 'OR', 'Oregon');
insert into states (country, code, name) values ('US', 'CA', 'California');
insert into states (country, code, name) values ('GB', 'ENG', 'England');

insert into people (id, name, state, country) values (1, 'AA', 'OR', 'US');
insert into people (id, name, state, country) values (2, 'BB', 'CA', 'US');
insert into people (id, name, state, country) values (3, 'CC', 'CA', 'US');
insert into people (id, name, state, country) values (4, 'DD', null, 'SG');
insert into people (id, name, state, country) values (5, 'EE', 'Singapore', 'SG');
insert into people (id, name, state, country) values (6, 'FF', 'ENG', 'GB');
insert into people (id, name, state, country) values (7, 'GG', 'ENG', 'GB');
insert into people (id, name, state, country) values (8, 'HH', 'ENG', 'GB');

insert into now_profiles (id) values (1);
insert into now_profiles (id) values (2);
insert into now_profiles (id) values (3);
insert into now_profiles (id) values (4);
insert into now_profiles (id) values (5);
insert into now_profiles (id) values (6);
insert into now_profiles (id) values (7);
insert into now_profiles (id) values (8);

select plan(3);

select results_eq(
	'select url, count from nnn.places()',
	$$values ('GB-ENG', 3), ('SG', 2), ('US-CA', 2), ('US-OR', 1)$$,
	'count'
);

select results_eq(
	'select url, name from nnn.places()',
	$$values
	('GB-ENG', 'GB: England'),
	('SG', 'Singapore'),
	('US-CA', 'US: California'),
	('US-OR', 'US: Oregon')$$,
	'name'
);

select results_eq(
	'select url, country, state from nnn.places()',
	$$values
	('GB-ENG', 'GB'::char(2), 'ENG'),
	('SG', 'SG'::char(2), null),
	('US-CA', 'US'::char(2), 'CA'),
	('US-OR', 'US'::char(2), 'OR')$$,
	'separate country and state for queries'
);

