select plan(19);

select is(json_array_length(f), 1),
	is((f -> 0 ->> 'start')::integer, 3, '0-indexed inclusive start'),
	is((f -> 0 ->> 'end')::integer, 10, 'exclusive end so stop before 10'),
	is(f -> 0 ->> 'url', 'https://dog.com')
from o.facets('my dog.com') f;

select is(json_array_length(f), 1),
	is((f -> 0 ->> 'start')::integer, 3),
	is((f -> 0 ->> 'end')::integer, 10, 'skip final !'),
	is(f -> 0 ->> 'url', 'https://dog.com')
from o.facets('my dog.com!') f;

select is(json_array_length(f), 1),
	is((f -> 0 ->> 'start')::integer, 7, '谢=3 bytes so 012,345 then space is 6'),
	is((f -> 0 ->> 'end')::integer, 14, 'skip final .'),
	is(f -> 0 ->> 'url', 'https://dog.com')
from o.facets('谢谢 dog.com.') f;

select is(json_array_length(f), 2),
	is((f -> 0 ->> 'start')::integer, 7),
	is((f -> 0 ->> 'end')::integer, 14),
	is(f -> 0 ->> 'url', 'https://dog.com'),
	is((f -> 1 ->> 'start')::integer, 22, '8 bytes between'),
	is((f -> 1 ->> 'end')::integer, 29),
	is(f -> 1 ->> 'url', 'https://cat.com')
from o.facets('谢谢 dog.com 谢谢 cat.com') f;

