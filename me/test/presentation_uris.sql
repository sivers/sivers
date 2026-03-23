insert into presentations (uri) values ('a');
insert into presentations (uri) values ('b');

select plan(1);
select results_eq('select me.presentation_uris() u order by u', array['a', 'b']);

