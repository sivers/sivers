select plan(2);

-- I would do way more tests here but they're covered in mash_template.sql

select is(o.jval4key('[{"a":"b"}]'::jsonb, 'a'), 'b');
select is(o.jval4key('[{"a":"b"},{"a":"boy"}]'::jsonb, 'a'), 'boy');

