select plan(3);

select is(o.rfc3339('2025-10-19 12:34:56+00'::timestamptz),
	'2025-10-19T12:34:56Z');

select is(o.rfc3339('2025-01-19 12:34:56+08'::timestamptz),
	'2025-01-19T04:34:56Z');

select is(o.rfc3339('2025-10-22 12:34:56-04'::timestamptz),
	'2025-10-22T16:34:56Z');

