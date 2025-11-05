insert into configs (k, v) values ('akey', 'a value');
insert into configs (k, v) values ('bkey', 'b value');

select plan(4);

select is(o.config('akey'), 'a value');
select is(o.config('bkey'), 'b value');
select is(o.config('Xkey'), null);
select is(o.config(null), null);

