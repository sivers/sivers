-- 1. table name to update
-- 2. where id = %d
-- 3. json of new key:vals
-- 4. WHITELIST array of colnames to update
-- 5. array of colnames to make NULL if that JSON value is empty
create function o.update_white(_table text, _id integer, _nu json, _ok text[], _nullcols text[]) returns void as $$
declare
	tmp json;
	colname text;
begin
	-- go through whitelist of colnames OK to update for this table
	foreach colname in array $4 loop
		-- if this colname exists in the JSON and is not null, then
		if $3 ->> colname is not null then
			-- if it's a nullcol and empty, then null it
			if colname = any($5) and regexp_replace($3 ->> colname, '\s', '', 'g') = '' then
				execute format('update %s set %I = null where id = %L', $1, colname, $2);
			else
				-- build a quick temporary one-key json to use for the update
				-- (doing this so incoming JSON could have bad values if key ignored anyway)
				-- (Example: {"id":"a"} instead of id integer.)
				tmp = json_build_object(colname, $3 -> colname);
				-- turn it into the correct type to match table, then update by select
				execute format('update %s set %I = (
					select %I from json_populate_record(null::%s, $1)
				) where id = %L',
				$1, colname, colname, $1, $2) using tmp;
			end if;
		end if;
	end loop;
end;
$$ language plpgsql;
