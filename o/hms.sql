-- given seconds as real (example videotext.startime)
-- return H:MM:SS.ms - for Advanced SubStation Alpha subtitles
create function o.hms(_seconds real) returns text as $$
select
	(ms / 3600000)::int::text || ':' ||
	lpad(((ms % 3600000) / 60000)::int::text, 2, '0') || ':' ||
	lpad(((ms % 60000) / 1000)::int::text, 2, '0') || '.' ||
	lpad(((ms % 1000) / 10)::int::text, 2, '0')
from (	-- first convert to milliseconds to prevent float problems
	select floor($1 * 1000)::bigint as ms
) s;
$$ language sql immutable;

