-- PURPOSE:
-- <select>
-- <option value="a">Apple</option>
-- <option value="b" selected>Boy</option>
-- </select>
-- Often used in logic-less HTML templates, so unify that " selected" logic here.
-- So Mustache loop looks like:
-- {{#options}}
-- <option value="{{code}}"{{selected}}>{{show}}</option>
-- {{/options}}
--
-- INPUT:
-- $1 = JSONB array of scalars or objects where one key is 'code'
-- $2 = the code that should be selected
-- OUTPUT:
-- JSONB array of objects where selected code is ' selected'.
-- Object keys: code, show, selected
--
-- EXAMPLE1:
-- o.select1('["a","b"]'::jsonb, 'b');
-- returns:
-- [{"code": "a", "show": "a", "selected": ""}, {"code": "b", "show": "b", "selected": " selected"}]
--
-- EXAMPLE2:
-- o.select1('[{"code":"a", "name":"Apple"},{"code":"b", "name":"Boy"}]'::jsonb, 'a');
-- returns:
-- [{"code": "a", "show": "Apple", "selected": " selected"}, {"code": "b", "show": "Boy", "selected": ""}]

create function o.select1(arr jsonb, sel text) returns jsonb as $$
	select coalesce(jsonb_agg(
		jsonb_build_object(
			'code', v_code,
			'show', v_show,
			'selected', case when v_code = sel then ' selected' else '' end
		)
	), '[]'::jsonb)
	from jsonb_array_elements(arr) as elem
	cross join lateral (
		select
			case when jsonb_typeof(elem) = 'object' then elem ->> 'code' else elem #>> '{}' end as v_code,
			case when jsonb_typeof(elem) = 'object' then (
				select value from jsonb_each_text(elem) where key <> 'code' limit 1
			) else elem ->> 0 end as v_show
	) as extracted;
$$ language sql immutable;

