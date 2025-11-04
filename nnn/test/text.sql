insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('SG','Singapore');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');
insert into people (id, name, city, state, country) values (1, 'AA', 'Manchester', 'ENG', 'GB');
insert into people (id, name, city, state, country) values (2, 'BB', 'Swansea', 'WLS', 'GB');
insert into people (id, name, city, state, country) values (3, 'CC', null, 'ENG', 'GB');
insert into people (id, name, city, state, country) values (4, 'DD', 'Singapore', null, 'SG');
insert into people (id, name, city, state, country) values (5, 'EE', 'Singapore', 'Singapore', 'SG');
insert into now_pages (person_id, created_at, updated_at, checked_at, long) values (4, '2025-01-01', '2025-01-01', '2025-01-01', 'https://dd.sg/');
insert into now_pages (person_id, created_at, updated_at, checked_at, long) values (3, '2025-01-02', '2025-02-02', '2025-02-02', 'https://cc.uk/');
insert into now_pages (person_id, created_at, updated_at, checked_at, long) values (2, '2025-03-03', '2025-04-04', '2025-04-14', 'https://bb.uk/');
insert into now_pages (person_id, created_at, updated_at, checked_at, long) values (5, '2025-03-30', '2025-03-30', '2025-04-14', 'https://ee.sg/');
insert into now_pages (person_id, created_at, updated_at, checked_at, long) values (1, '2025-03-30', '2025-03-30', '2025-04-14', 'https://aa.uk/');

select plan(1);
select is(body, e'name\tcity\tstate\tcountry\tcreated\tupdated\tchecked\turl
DD\tSingapore\t\tSG\t2025-01-01\t2025-01-01\t2025-01-01\thttps://dd.sg/
CC\t\tENG\tGB\t2025-01-02\t2025-02-02\t2025-02-02\thttps://cc.uk/
BB\tSwansea\tWLS\tGB\t2025-03-03\t2025-04-04\t2025-04-14\thttps://bb.uk/
AA\tManchester\tENG\tGB\t2025-03-30\t2025-03-30\t2025-04-14\thttps://aa.uk/
EE\tSingapore\tSingapore\tSG\t2025-03-30\t2025-03-30\t2025-04-14\thttps://ee.sg/\n')
from nnn.text();

