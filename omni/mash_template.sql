-- given a Mustache template and data, convert data to stack, and parse
create or replace function o.mash_template(template text, data jsonb) returns text as $$
declare
	txt text = template;
	key text;
begin
	-- normalize to a context stack (array, bottom..top)
	if coalesce(jsonb_typeof(data), '') != 'array' then
		data = jsonb_build_array(coalesce(data, '{}'::jsonb));
	end if;

	-- strip comments (standalone and inline)
	txt = regexp_replace(txt, '(^|\r?\n)[ \t]*\{\{![^}]*\}\}[ \t]*(\r?\n|$)', '\1', 'g');
	txt = regexp_replace(txt, '\{\{![^}]*\}\}', '', 'g');

	-- sections: normal first, then inverted
	txt = o.mash_sections(txt, data, false); -- {{#name}}...{{/name}}
	txt = o.mash_sections(txt, data, true);  -- {{^name}}...{{/name}}

	-- unescaped: {{{name}}}
	for key in
		select distinct m[1] from regexp_matches(txt, '\{\{\{([a-z0-9_.-]+)\}\}\}', 'g') as m
	loop
		txt = replace(txt, '{{{' || key || '}}}', o.jval4key(data, key));
	end loop;

	-- escaped: {{name}}
	for key in
		select distinct m[1] from regexp_matches(txt, '\{\{([a-z0-9_.-]+)\}\}', 'g') as m
	loop
		txt = replace(txt, '{{' || key || '}}', o.escape_html(o.jval4key(data, key)));
	end loop;

	return txt;
end;
$$ language plpgsql immutable;
