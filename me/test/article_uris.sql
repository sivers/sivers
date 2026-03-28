insert into articles (uri, posted, title) values ('three', '2026-01-03', 'Title Three');
insert into articles (uri, posted, title) values ('four', '2026-01-04', 'Title Four');
insert into articles (uri, posted, title) values ('future', '2099-01-04', 'Future Post');
insert into articles (title) values ('Not Yet');

select plan(2);
select is(2::bigint, count(*)) from me.article_uris();
select results_eq('select uri from me.article_uris() order by uri', array['four', 'three']);

