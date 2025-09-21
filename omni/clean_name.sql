-- inside-out:
-- 1. replace all whitespace characters (tab, newline) with a space
-- 2. trim the head and tail of spaces (leaving inside space)
-- 3. strip HTML tags
create function o.clean_name(_name text, out name text) as $$
	select regexp_replace(btrim(regexp_replace($1, '\s+', ' ', 'g')), '</?[^>]+?>', '', 'g');
$$ language sql immutable strict parallel safe;

