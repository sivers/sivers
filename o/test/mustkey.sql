select plan(2);

-- I would do way more tests here but they're covered in must_template.sql

select is(o.mustkey('[{"a":"b"}]'::jsonb, 'a'), 'b');
select is(o.mustkey('[{"a":"b"},{"a":"boy"}]'::jsonb, 'a'), 'boy');

