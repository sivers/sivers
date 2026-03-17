-- 1. table name to update
-- 2. where id = %d
-- 3. json of new key:vals
-- 4. array of BLACKLIST colnames to NOT update
-- 5. array of colnames to make NULL if that JSON value is empty
create function o.update_black(_table text, _id integer, _nu json, _no text[], _nullcols text[]) returns void as $$
declare
	tmp json;
	col record;
begin
	-- go through whitelist of colnames OK to update for this table
	for col in
	select column_name::text as name
	from information_schema.columns
	where table_name = $1
	and column_name != all($4) loop
		-- if this colname exists in the JSON and is not null, then
		if $3 ->> col.name is not null then
			-- if it's a nullcol and empty, then null it
			if col.name = any($5) and regexp_replace($3 ->> col.name, '\s', '', 'g') = '' then
				execute format ('update %s set %I = null where id = %L', $1, col.name, $2);
			else
				-- build a quick temporary one-key json to use for the update
				-- (doing this so incoming JSON could have bad values if key ignored anyway)
				-- (Example: {"id":"a"} instead of id integer.)
				tmp = json_build_object(col.name, $3 -> col.name);
				-- turn it into the correct type to match table, then update by select
				execute format ('update %s set %I = (
					select %I from json_populate_record(null::%s, $1)
				) where id = %L',
				$1, col.name, col.name, $1, $2) using tmp;
			end if;
		end if;
	end loop;
end;
$$ language plpgsql;
