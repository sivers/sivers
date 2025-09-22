create or replace function o.mash_sections(template text, data jsonb, inverted boolean) returns text as $$
declare
	-- parsed template accumulator
	txt text = template;

	-- tag handling
	key text;
	opener char(1) = case when inverted then '^' else '#' end;
	open_tag text;
	close_tag text;
	open_pos int;
	close_pos_rel int;
	search_from int;
	depth int;
	before text;
	after text;
	section_content text;
	rest text;
	next_open_rel int;
	next_close_rel int;

	-- standalone trimming helpers
	open_standalone boolean;
	close_standalone boolean;
	lastline_before text;
	lastline_content text;

	-- context resolution
	val jsonb;
	rendered text;
	innerc text;

	-- iteration helpers
	i int;
	n int;
	ctx jsonb;
	p text[];
	cand_json jsonb;

	-- NEW: detect nested same-key normal section
	has_nested_same boolean;
begin
	loop
		-- find leftmost opener of this kind and capture its key
		select m[1] into key from regexp_match(txt, format('\{\{\%s([a-z0-9_.-]+)\}\}', opener)) as m;
		exit when key is null;

		open_tag  = '{{' || opener || key || '}}';
		close_tag = '{{/' || key || '}}';

		open_pos = strpos(txt, open_tag);
		if open_pos = 0 then
			exit;
		end if;

		after = substr(txt, open_pos + length(open_tag));

		-- walk forward to the matching closer, accounting for nested same-key/same-kind
		depth = 1;
		search_from = 1;
		close_pos_rel = 0;
		loop
			rest = substr(after, search_from);
			next_open_rel  = strpos(rest, open_tag);
			next_close_rel = strpos(rest, close_tag);

			if next_open_rel = 0 and next_close_rel = 0 then
				close_pos_rel = 0;
				exit;
			end if;

			if next_open_rel > 0 and (next_close_rel = 0 or next_open_rel < next_close_rel) then
				depth = depth + 1;
				search_from = search_from + next_open_rel + length(open_tag);
			else
				depth = depth - 1;
				if depth = 0 then
					close_pos_rel = search_from + next_close_rel - 1;
					exit;
				else
					search_from = search_from + next_close_rel + length(close_tag);
				end if;
			end if;
		end loop;

		-- unmatched opener? stop
		if close_pos_rel = 0 then
			exit;
		end if;

		-- slice parts
		section_content = substr(after, 1, close_pos_rel - 1);
		before = substr(txt, 1, open_pos - 1);
		after  = substr(after, close_pos_rel + length(close_tag));

		-- standalone opener/closer trimming (based on original slices)
		lastline_before = regexp_replace(before, '.*[\n\r]', '');
		open_standalone = (lastline_before ~ '^[ \t]*$') and (section_content ~ '^[ \t]*\r?\n');

		lastline_content = regexp_replace(section_content, '.*[\n\r]', '');
		close_standalone = (lastline_content ~ '^[ \t]*$') and (after ~ '^[ \t]*(\r?\n|$)');

		-- resolve section value against the context stack (top..down)
		val = null;
		if key = '.' then
			n = jsonb_array_length(data);
			if n > 0 then
				val = data -> (n - 1);
			end if;
		else
			p = regexp_split_to_array(key, '\.');
			n = jsonb_array_length(data);
			i = n;
			while i >= 1 loop
				ctx = data -> (i - 1);
				if jsonb_typeof(ctx) = 'object' then
					cand_json = ctx #> p;
					if cand_json is not null then
						val = cand_json;
						exit;
					end if;
				end if;
				i = i - 1;
			end loop;
		end if;

		-- decide whether to render
		if (inverted and o.falsey(val)) or (not inverted and not o.falsey(val)) then
			-- apply standalone trimming before recursion
			innerc = section_content;
			if open_standalone then
				before = regexp_replace(before, '[ \t]*$', '');
				innerc = regexp_replace(innerc, '^[ \t]*\r?\n', '');
			end if;
			if close_standalone then
				innerc = regexp_replace(innerc, '[ \t]*$', '');
				after  = regexp_replace(after, '^[ \t]*(\r?\n)?', '');
			end if;

			-- render with appropriate stack
			rendered = '';
			if inverted then
				-- inverted: render once with current stack
				rendered = o.mash_template(innerc, data);
			else
				if coalesce(jsonb_typeof(val), '') = 'array' then
					-- guard-only for nested same-key section: render once, don't iterate here
					has_nested_same := (strpos(innerc, '{{#' || key || '}}') > 0);
					if has_nested_same then
						rendered = o.mash_template(innerc, data);
					else
						-- normal list iteration
						for ctx in select value from jsonb_array_elements(val) loop
							rendered = rendered || o.mash_template(innerc, data || jsonb_build_array(ctx));
						end loop;
					end if;
				elsif val is null then
					-- safety (null would have been falsey)
					rendered = rendered || o.mash_template(innerc, data);
				else
					-- push object/scalar/true and render once
					rendered = rendered || o.mash_template(innerc, data || jsonb_build_array(val));
				end if;
			end if;

			txt = before || rendered || after;

		else
			-- omit section but keep outer trimming
			if open_standalone then
				before = regexp_replace(before, '[ \t]*$', '');
			end if;
			if close_standalone then
				after = regexp_replace(after, '^[ \t]*(\r?\n)?', '');
			end if;
			txt = before || after;
		end if;
	end loop;
	return txt;
end;
$$ language plpgsql immutable;

