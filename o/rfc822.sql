-- RFC 822 date format, given timestamp, outputs GMT:
-- Wed, 22 Oct 2025 12:34:56 GMT
create function o.rfc822(ts timestamptz) returns text as $$
  select to_char(ts at time zone 'UTC', 'Dy, DD Mon YYYY HH24:MI:SS "GMT"');
$$ language sql immutable;
