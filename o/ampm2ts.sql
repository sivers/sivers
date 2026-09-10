-- for the purpose of hand-typing a time into a box, and getting a timestamptz:
-- INPUT:
-- $1 timezone name from pg_timezone_names.name - example "Europe/Istanbul"
-- $2 "YYYY-MM-DD H am/pm" - example: "2026-09-22 3pm" or "2027-01-13 11 AM"
-- OUTPUT:
-- timestamptz(0) (in UTC)

create function o.ampm2ts(_tzname text, _ampm text,
	out ts timestamptz(0)) as $$
declare
    parts     text[];
    hour12    integer;
    local_ts  timestamp without time zone;
begin
    if not exists (
        select 1 from pg_catalog.pg_timezone_names where name = $1
    ) then
        raise exception 'wrong tz name: %', $1;
    end if;

    parts = regexp_match(lower(btrim($2)), '^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]+) ?(am|pm)$');
    if parts is null then
        raise exception 'wrong ampm format: %', $2;
    end if;

    hour12 = parts[4]::integer;
    if hour12 not between 1 and 12 then
        raise exception 'wrong hour: %', parts[4];
    end if;

    ts = make_timestamp(
        parts[1]::integer,
        parts[2]::integer,
        parts[3]::integer,
        (hour12 % 12) + case parts[5] when 'pm' then 12 else 0 end,
        0, 0
    ) at time zone $1;
end;
$$ language plpgsql stable;
