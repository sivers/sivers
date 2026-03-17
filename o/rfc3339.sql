-- RFC 3339 date format, given timestamp, outputs UTC:
-- 2026-03-10T14:00:00Z
create function o.rfc3339(ts timestamptz) returns text as $$
	select to_char(ts at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"');
$$ language sql immutable;
