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
	search_from int;
	before text;
	after text;
	section_content text;

	-- vars for finding matching closer
	nesting_level int;           -- depth of nested same-key sections
	cursor_position int;         -- current search position within 'after' text
	matching_close_position int; -- final position of the matching closer tag
	remaining_text text;         -- substring currently searching
	next_open_offset int;        -- distance to next opening tag in remaining_text
	next_close_offset int;       -- distance to next closing tag in remaining_text

	-- standalone trimming helpers
	open_standalone boolean;
	close_standalone boolean;
	lastline_before text;
	lastline_content text;

	-- context resolution
	val jsonb;
	rendered text;
	innerc text;

	-- iteration helper
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

		-- walk forward to find matching closer, minding nested same-key/same-kind sections.
		-- use a nesting level counter: start at 1 for the opener already found,
		-- increment when another opener found, decrement when closer found.
		-- when nesting level reaches 0, we've found the matching closer.
		nesting_level = 1;
		cursor_position = 1;
		matching_close_position = 0;
		loop
			-- get string from current cursor position to end
			remaining_text = substr(after, cursor_position);
			
			-- find next opening and closing tags in remaining text
			next_open_offset  = strpos(remaining_text, open_tag);
			next_close_offset = strpos(remaining_text, close_tag);

			-- neither tag found? unmatched opener
			if next_open_offset = 0 and next_close_offset = 0 then
				matching_close_position = 0;
				exit;
			end if;

			-- check which tag comes first (or if only one exists)
			if next_open_offset > 0 and (next_close_offset = 0 or next_open_offset < next_close_offset) then
				-- found an opening tag first - this is a nested section with the same key
				-- increment nesting level and move cursor past this opening tag
				nesting_level = nesting_level + 1;
				cursor_position = cursor_position + next_open_offset + length(open_tag) - 1;
			else
				-- found a closing tag first (or it's the only one), so decrement nesting level
				nesting_level = nesting_level - 1;
				if nesting_level = 0 then
					-- matching closer. calculate its position relative to 'after'
					matching_close_position = cursor_position + next_close_offset - 1;
					exit;
				else
					-- closer matched a nested opener, keep searching
					-- move cursor past this closing tag
					cursor_position = cursor_position + next_close_offset + length(close_tag) - 1;
				end if;
			end if;
		end loop;

		-- unmatched opener? stop
		if matching_close_position = 0 then
			exit;
		end if;

		-- slice parts
		section_content = substr(after, 1, matching_close_position - 1);
		before = substr(txt, 1, open_pos - 1);
		after  = substr(after, matching_close_position + length(close_tag));

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
