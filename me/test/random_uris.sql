insert into articles (uri, posted, title) values ('three', '2026-01-03', 'Title Three');
insert into articles (uri, posted, title) values ('four', '2026-01-04', 'Title Four');
insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '2026-02-08', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 8, '2026-02-09', '.');
insert into interviews (uri, summary) values ('2026-01-one', 'interview one');
insert into interviews (uri, summary) values ('2026-02-two', 'interview two');
insert into presentations (uri) values ('prez1');
insert into presentations (uri) values ('prez2');
insert into meetwheres (id, display) values (1, '2025-01 - One Place');
insert into meetwheres (id, display) values (2, '2026-02 - Two Place');
insert into people (id, name) values (1, 'Mrs. One');
insert into people (id, name) values (2, 'Mr. Two');
insert into people (id, name) values (3, 'Miss Three');
insert into people (id, name) values (4, 'Sir Four');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (1, 1, 1, '2025-01-15 12:00:00+00', 'topics one', 'notes one');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (2, 1, 3, '2025-01-16 12:00:00+00', 'three topics', 'three notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (3, 2, 2, '2026-02-22 12:00:00+00', 'two topics', 'two notes');
insert into meetings (id, where_id, person_id, whatime, topics, notes) values (4, 2, 4, '2026-02-04 12:00:00+00', 'topics four', 'notes four');

select plan(1);
select results_eq('select uri from me.random_uris() order by uri', array[
	'2026-01-one',
	'2026-02-two',
	'book/BookEight',
	'book/BookNine',
	'four',
	'met/1',
	'met/2',
	'met/3',
	'met/4',
	'met/at-1',
	'met/at-2',
	'prez1',
	'prez2',
	'three'
]);

