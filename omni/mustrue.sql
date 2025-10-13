-- Mustache value is true if not one of these falses
create function o.mustrue(jsonb) returns boolean as $$
	select not (($1 is null)
	or (jsonb_typeof($1) = 'null')
	or (jsonb_typeof($1) = 'boolean' and not ($1::text::boolean))
	or (jsonb_typeof($1) = 'array' and jsonb_array_length($1) = 0));
$$ language sql immutable parallel safe;

