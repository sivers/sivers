-- For Mustache: get value for a key in the data/context stack.
-- key="." returns the scalar top-of-stack (objects/arrays => "").
-- Dotted paths traverse objects from the top of the stack downward.
create or replace function o.jval4key(data jsonb, key text) returns text as $$
declare
	val text = '';
	n int;
	i int;
	ctx jsonb;
	p text[];
	cand text;
	jt text;
begin
	if key = '.' then
		n = coalesce(jsonb_array_length(data), 0);
		if n > 0 then
			ctx = data -> (n - 1);
			jt = coalesce(jsonb_typeof(ctx), '');
			if jt in ('string', 'number', 'boolean', 'null') then
				if jt = 'string' then
					val = regexp_replace(ctx::text, '^"(.*)"$', '\1');
				elsif jt = 'null' then
					val = '';
				else
					val = ctx::text;
				end if;
			else
				val = '';
			end if;
		end if;
	else
		p = regexp_split_to_array(key, '\.');
		n = coalesce(jsonb_array_length(data), 0);
		i = n;
		while i >= 1 loop
			ctx = data -> (i - 1);
			if jsonb_typeof(ctx) = 'object' then
				cand = ctx #>> p;
				if cand is not null then
					val = cand;
					exit;
				end if;
			end if;
			i = i - 1;
		end loop;
		val = coalesce(val, '');
	end if;
	return val;
end;
$$ language plpgsql immutable;
