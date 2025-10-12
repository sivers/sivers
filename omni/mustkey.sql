-- for Mustache key to get value from JSON stack
-- used by o.mustkey (below) and o.must_sections
create or replace function o.mustkeyj(data jsonb, key text) returns jsonb as $$
declare
	stack_size int = coalesce(jsonb_array_length(data), 0);
	i int; -- frame index
	this1 jsonb;
begin
	i = stack_size - 1;
	-- key="." returns the scalar top-of-stack (objects/arrays => "").
	if key = '.' then
		if stack_size = 0 then
			return null;
		end if;
		return data -> i;
	end if;
	-- or look for dotted paths from end of array
	while i >= 0 loop
		this1 = data -> i;
		-- #> text[] extracts JSON at the specified (array!) path
		if jsonb_typeof(this1) = 'object' and this1 #> string_to_array(key, '.') is not null then
			return this1 #> string_to_array(key, '.');
		end if;
		i = i - 1;
	end loop;
	return null;
end;
$$ language plpgsql immutable;

create or replace function o.mustkey(data jsonb, key text) returns text as $$
declare
	j jsonb;
begin
	j = o.mustkeyj($1, $2);
	if j is not null and jsonb_typeof(j) in ('string', 'number', 'boolean') then
		return j #>> '{}'; -- unquote strings and convert numbers/booleans to text
	else
		return '';
	end if;
end;
$$ language plpgsql immutable;

