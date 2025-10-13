select plan(7);

select is(o.mustrue(null), false, 'null');
select is(o.mustrue('null'::jsonb), false, 'j-null');
select is(o.mustrue('"null"'::jsonb), true, '"null"');
select is(o.mustrue('false'::jsonb), false, 'j-false');
select is(o.mustrue('true'::jsonb), true, 'j-true');
select is(o.mustrue('[]'::jsonb), false, '0-array');
select is(o.mustrue('["a"]'::jsonb), true, '1-array');

