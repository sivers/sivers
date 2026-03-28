insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '2026-02-08', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 8, '2026-02-09', '.');
insert into ebooks (code, title, author) values ('BookTed', 'Book Ted', 'Ted Author');

select plan(2);
select is(2::bigint, count(*)) from me.book_uris();
select results_eq('select uri from me.book_uris() order by uri', array['BookEight', 'BookNine']);

