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
	text_before_opener text;
	text_after_closer text;
	content_between_tags text;

	-- vars for finding matching closer
	nesting_level int;           -- depth of nested same-key sections
	cursor_position int;         -- current search position within 'after' text
	matching_close_position int; -- final position of the matching closer tag
	remaining_text text;         -- substring currently searching
	next_open_offset int;        -- distance to next opening tag in remaining_text
	next_close_offset int;       -- distance to next closing tag in remaining_text

	-- trimming of standalone
	opener_is_standalone boolean;
	closer_is_standalone boolean;
	final_line_before_opener text;
	final_line_of_content text;

	-- context resolution
	val jsonb;
	rendered text;
	trimmed_section_content text;
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

		text_after_closer = substr(txt, open_pos + length(open_tag));

		-- walk forward to find matching closer, minding nested same-key/same-kind sections.
		-- use a nesting level counter: start at 1 for the opener already found,
		-- increment when another opener found, decrement when closer found.
		-- when nesting level reaches 0, we've found the matching closer.
		nesting_level = 1;
		cursor_position = 1;
		matching_close_position = 0;
		loop
			-- get string from current cursor position to end
			remaining_text = substr(text_after_closer, cursor_position);
			
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

		-- text before opener, between tags, and after closer - for later rendering or skipping
		content_between_tags = substr(text_after_closer, 1, matching_close_position - 1);
		text_before_opener = substr(txt, 1, open_pos - 1);
		text_after_closer  = substr(text_after_closer, matching_close_position + length(close_tag));

		-- next 4 lines are just to see if opener and closer tags are standalone
		-- (lines that have only the tag and whitespace). if so, trim whitespace later
		final_line_before_opener = regexp_replace(text_before_opener, '.*[\n\r]', '');
		opener_is_standalone = (final_line_before_opener ~ '^[ \t]*$') and (content_between_tags ~ '^[ \t]*\r?\n');
		final_line_of_content = regexp_replace(content_between_tags, '.*[\n\r]', '');
		closer_is_standalone = (final_line_of_content ~ '^[ \t]*$') and (text_after_closer ~ '^[ \t]*(\r?\n|$)');

		-- given key, get value from datajson, if any
		val = o.mustkeyj(data, key);

		-- render if val is true (or if section is inverted, then if val is false)
		if (o.mustrue(val) and not inverted) or (inverted and not o.mustrue(val)) then
			-- if standalone, strip whitespace
			trimmed_section_content = content_between_tags;
			if opener_is_standalone then
				text_before_opener = regexp_replace(text_before_opener, '[ \t]*$', '');
				trimmed_section_content = regexp_replace(trimmed_section_content, '^[ \t]*\r?\n', '');
			end if;
			if closer_is_standalone then
				trimmed_section_content = regexp_replace(trimmed_section_content, '[ \t]*$', '');
				text_after_closer  = regexp_replace(text_after_closer, '^[ \t]*(\r?\n)?', '');
			end if;

			-- recursively render section content, managing data context stack
			-- data stack is jsonb array - look up values from the end backwards
			rendered = '';
			if inverted then
				-- inverted sections render once with current data stack unchanged
				rendered = o.must_template(trimmed_section_content, data);
			else
				-- normal sections vary rendering based on the value type
				if coalesce(jsonb_typeof(val), '') = 'array' then
					-- if array, content has nested section with same key? ({{#items}}{{#items}}{{/items}}{{/items}})
					if (strpos(trimmed_section_content, '{{#' || key || '}}') > 0) then
						-- render once without iterating here. let inner recursive call handle iteration
						rendered = o.must_template(trimmed_section_content, data);
					else
						-- no nested same-key section: iterate over array elements
						-- for each element, push onto data stack and render content
						for this1 in select value from jsonb_array_elements(val) loop
							rendered = rendered || o.must_template(
								trimmed_section_content,
								data || jsonb_build_array(this1)
							);
						end loop;
					end if;
				elsif val is not null then
					-- if val not array and not null, must be scalar
					-- push onto data stack and render once
					rendered = rendered || o.must_template(
						trimmed_section_content,
						data || jsonb_build_array(val)
					);
				end if;
			end if;
			
			-- reassemble template: text before section + rendered content + text after section
			txt = text_before_opener || rendered || text_after_closer;
		else
			-- value is falsey: omit the section entirely, but preserve standalone whitespace trimming
			if opener_is_standalone then
				text_before_opener = regexp_replace(text_before_opener, '[ \t]*$', '');
			end if;
			if closer_is_standalone then
				text_after_closer = regexp_replace(text_after_closer, '^[ \t]*(\r?\n)?', '');
			end if;
			txt = text_before_opener || text_after_closer;
		end if;
	end loop;
	return txt;
end;
$$ language plpgsql immutable;
