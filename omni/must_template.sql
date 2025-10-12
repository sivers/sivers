-- Mustache parser
create or replace function o.must_template(template text, data jsonb) returns text as $$
declare
	txt text = template;
	key text;
begin
	-- data jsonb now always an array (wraps object into [])
	if jsonb_typeof(data) != 'array' then
		data = jsonb_build_array(data);
	end if;

	txt = o.must_sections(txt, data, false); -- {{#name}}...{{/name}}
	txt = o.must_sections(txt, data, true);  -- {{^name}}...{{/name}}

	-- unescaped: {{{name}}}
	for key in
		select distinct m[1] from regexp_matches(txt, '\{\{\{([a-z0-9_.]+)\}\}\}', 'g') as m
	loop
		txt = replace(txt, '{{{' || key || '}}}', o.mustkey(data, key));
	end loop;

	-- escaped: {{name}}
	for key in
		select distinct m[1] from regexp_matches(txt, '\{\{([a-z0-9_.]+)\}\}', 'g') as m
	loop
		txt = replace(txt, '{{' || key || '}}', o.escape_html(o.mustkey(data, key)));
	end loop;

	return txt;
end;
$$ language plpgsql immutable;
