insert into interviews (uri, summary) values ('2026-01-one', 'interview one');
insert into interviews (uri, summary) values ('2026-02-two', 'interview two');
insert into interviews (name) values ('future one');

select plan(2);
select is(2::bigint, count(*)) from me.interview_uris();
select results_eq('select uri from me.interview_uris() order by uri', array['2026-01-one', '2026-02-two']);

