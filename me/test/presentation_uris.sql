insert into presentations (uri) values ('a');
insert into presentations (uri) values ('b');

select plan(1);
select results_eq('select uri from me.presentation_uris() order by uri', array['a', 'b']);

