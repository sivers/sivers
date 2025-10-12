-- For Mustache: get value for a key in the JSONB data
create or replace function o.jval4key(data jsonb, key text) returns text as $$
declare
	stack_size int = coalesce(jsonb_array_length(data), 0);
	i int; -- frame index
	this1 jsonb;
begin
	-- key="." returns the scalar top-of-stack (objects/arrays => "").
	if key = '.' then
		if stack_size = 0 then
			return '';
		end if;
		i = stack_size - 1;
		this1 = data -> i;
		case coalesce(jsonb_typeof(this1), '')
			when 'string' then return data ->> i; -- ->> to unquote text
			when 'number', 'boolean' then return this1::text;
			when 'null' then return '';
			else return '';
		end case;
	end if;
	-- or look for dotted paths from end of array
	i = stack_size - 1;
	while i >= 0 loop
		this1 = data -> i;
		-- #>> text[] extracts JSON sub-object at the specified (array!) path as text
		if jsonb_typeof(this1) = 'object' and this1 #>> string_to_array(key, '.') is not null then
			return this1 #>> string_to_array(key, '.');
		end if;
		i = i - 1;
	end loop;
	return '';
end;
$$ language plpgsql immutable;

