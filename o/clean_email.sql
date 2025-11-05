-- from inside out:
-- 1. delete '<'
-- 2. delete '>'
-- 3. delete all whitespace
-- 4. lowercase
create function o.clean_email(_email text, out email text) as $$
	select lower(regexp_replace(replace(replace($1, '<', ''), '>', ''), '\s', '', 'g'));
$$ language sql immutable strict parallel safe;
