select plan(1);

-- I don't really understand this

select is(o.mash_sections('{{#person}}{{name}}{{/person}}', '[{"person":{"name":"Derek"}}]'::jsonb, false), 'Derek');

