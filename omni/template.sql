-- code = templates.code of the Mustache-y template to parse
-- data JSONB of values to interpolate (or NULL)
create function o.template(code varchar(32), data jsonb) returns text as $$
	select o.must_template(
		(select template from templates where templates.code = $1),
		coalesce($2, '{}'::jsonb)
	);
$$ language sql immutable;

-- parses corecode($2) template first, then passes it as the 'core' to wrapcode($1) template
-- wrapcode = templates.code of the wrap-around (header and footer) with {{{core}}} where body should be
-- corecode = templates.code of the main body inside
-- data must be a hash-JSONB (or NULL) not array-JSONB, and will be shared with both core and wrapper
create function o.template(wrapcode varchar(32), corecode varchar(32), data jsonb) returns text as $$
	select o.must_template(
		-- get 1st template as text
		(select template from templates where templates.code = $1),
		-- merge passed data with a new key/val: 'core'
		coalesce($3, '{}'::jsonb) || jsonb_build_object('core', (
				-- 'core' is 2nd template as text...
				select o.must_template(
					(select template from templates where templates.code = $2),
					-- parsed with the original passed data
					coalesce($3, '{}'::jsonb)
				)
		))
	);
$$ language sql stable;

