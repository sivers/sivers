select plan(7);

select is(o.falsey(null), true);
select is(o.falsey('null'::jsonb), true);
select is(o.falsey('"null"'::jsonb), false);
select is(o.falsey('false'::jsonb), true);
select is(o.falsey('true'::jsonb), false);
select is(o.falsey('[]'::jsonb), true);
select is(o.falsey('["a"]'::jsonb), false);

