insert into meetwheres (id, display) values (1, '2025-01 - One Place');
insert into meetwheres (id, display) values (2, '2026-02 - Two Place');
insert into meetwheres (id, display) values (3, '2099-12 - Future Place');

insert into people (id, name) values (1, 'Mrs. One');
insert into people (id, name) values (2, 'Mr. Two');
insert into people (id, name) values (3, 'Miss Three');
insert into people (id, name) values (4, 'Sir Four');
insert into people (id, name) values (5, 'Dr. Five');

insert into meetings (id, where_id, person_id, whatime, topics, notes) values (1, 1, 1, '2025-01-15 12:00:00+00', 'topics one', 'notes one');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (2, 1, 3, '2025-01-16 12:00:00+00', 'three topics', 'three notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (3, 2, 2, '2026-02-22 12:00:00+00', 'two topics', 'two notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (4, 2, 4, '2026-02-04 12:00:00+00', 'topics four', 'notes four');
insert into meetings (id, where_id, person_id, whatime, notes) values (5, 3, 5, '2099-12-12 12:00:00+00', 'FUTURE so unlisted');

select plan(2);

select is(2::bigint, count(*)) from me.metat_ids();
select results_eq('select me.metat_ids()', array[1,2]);
