insert into topics (uri) values ('test');
insert into articles (uri, topic, posted, title, original) values ('three', 'test', '2026-01-03', 'Title Three', '.');
insert into articles (uri, topic, posted, title, original) values ('four', 'test', '2026-01-04', 'Title Four', '.');
insert into articles (uri, topic, posted, title, original) values ('future', 'test', '2099-01-04', 'Future Post', '.');
insert into articles (title, original, topic) values ('Not Yet', '.', 'test');

select plan(2);
select is(2::bigint, count(*)) from me.article_uris();
select results_eq('select uri from me.article_uris() order by uri', array['four', 'three']);

