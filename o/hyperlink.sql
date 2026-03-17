-- * input: 'Look: https://example.com/ I like it!'
-- * output: 'Look: <a href="https://example.com/">example.com/</a> I like it!'
create function o.hyperlink(text) returns text as $$
	select regexp_replace($1,
        '(https://([^\s]+))',
        '<a href="\1">\2</a>',
        'g');
$$ language sql immutable strict parallel safe;
