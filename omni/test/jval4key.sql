select plan(2);

-- I don't really understand this

select is(o.jval4key('[{"a":"b"}]'::jsonb, 'a'), 'b');
select is(o.jval4key('[{"a":"b"},{"a":"boy"}]'::jsonb, 'a'), 'boy');

