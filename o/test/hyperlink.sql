select plan(1);

select is(o.hyperlink(
	'Look: https://example.com/ I like it! And this too: https://another.com/'),
	'Look: <a href="https://example.com/">example.com/</a> I like it! And this too: <a href="https://another.com/">another.com/</a>'
);

