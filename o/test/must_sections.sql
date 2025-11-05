select plan(2);

-- this is really tested inside must_template.sql

select is(o.must_sections('{{#person}}{{name}}{{/person}}', '[{"person":{"name":"Derek"}}]'::jsonb, false), 'Derek');
select is(o.must_sections('{{^person}}no people{{/person}}', '[]'::jsonb, true), 'no people');

