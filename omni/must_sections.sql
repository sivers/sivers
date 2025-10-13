create or replace function o.must_sections(template text, data jsonb, inverted boolean) returns text as $$
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
	stack_size int;
	this1 jsonb;
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

		-- given key, get value from datajson, if any
		val = o.mustkeyj(data, key);

		-- render if val is true (or if section is inverted, then if val is false)
		if (o.mustrue(val) and not inverted) or (inverted and not o.mustrue(val)) then
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
				rendered = o.must_template(innerc, data);
			else
				if coalesce(jsonb_typeof(val), '') = 'array' then
					-- nested same-key section? render once, don't iterate here
					if (strpos(innerc, '{{#' || key || '}}') > 0) then
						rendered = o.must_template(innerc, data);
					else
						-- normal list iteration
						for this1 in select value from jsonb_array_elements(val) loop
							rendered = rendered || o.must_template(innerc, data || jsonb_build_array(this1));
						end loop;
					end if;
				elsif val is null then
					-- safety (null would have been falsey)
					rendered = rendered || o.must_template(innerc, data);
				else
					-- push object/scalar/true and render once
					rendered = rendered || o.must_template(innerc, data || jsonb_build_array(val));
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

