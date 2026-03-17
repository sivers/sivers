select plan(3);

select is(o.rfc822('2025-10-19 12:34:56+00'::timestamptz),
	'Sun, 19 Oct 2025 12:34:56 GMT');

select is(o.rfc822('2025-01-19 12:34:56+08'::timestamptz),
	'Sun, 19 Jan 2025 04:34:56 GMT');

select is(o.rfc822('2025-10-22 12:34:56-04'::timestamptz),
	'Wed, 22 Oct 2025 16:34:56 GMT');

