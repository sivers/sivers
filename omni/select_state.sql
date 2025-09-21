-- for <select>
--   <option value="OH">Ohio</option>
--   <option value="OR" selected>Oregon</option>
create function o.select_state(cc char(2), statecode text) returns jsonb as $$
	select jsonb_object_agg(country, state_list) from (
		select country,
		jsonb_agg(jsonb_build_object(
			'code', code,
			'name', name,
			'selected', case when country = $1 and code = $2 then ' selected' else '' end
		) order by name) as state_list
		from states
		group by country
	) as t;
$$ language sql stable;

create function o.select_state() returns jsonb as $$
	select o.select_state(null, null);
$$ language sql stable;

