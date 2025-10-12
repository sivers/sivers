-- used by Mustache parser
create function o.falsey(jsonb) returns boolean as $$
	select ($1 is null)
	or (jsonb_typeof($1) = 'null')
	or (jsonb_typeof($1) = 'boolean' and not ($1::text::boolean))
	or (jsonb_typeof($1) = 'array' and jsonb_array_length($1) = 0);
$$ language sql immutable parallel safe;

