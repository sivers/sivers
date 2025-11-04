-- for social API posting, extracts URLs with start and end points
-- https://docs.bsky.app/docs/advanced-guides/post-richtext
-- (see tests for explanatory examples)
create function o.facets(text) returns json as $$
declare
	urlfinder text;
	matches text[];
	url text;
	search_at int = 1;
	start_at int;
	end_at int;
	objects json[] = '{}';
begin
	urlfinder = 'https?://[^\s]+|(?:[a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}(?:/[^\s]*)?';

	loop
		-- find next url starting from search_at
		matches = regexp_match(substring($1 from search_at), urlfinder);
		exit when matches is null;

		-- url doesn't include trailing punctuation ("wow.com!")
		url = regexp_replace(matches[1], '[.,;!?]+$', '');

		-- find position in original string
		start_at = position(url in substring($1 from search_at)) + search_at - 1;

		-- move next search position past this match
		search_at = start_at + length(url);

		-- calculate multibyte char start & end (0-indexed)
		start_at = octet_length(substring($1 from 1 for start_at - 1));
		-- range has inclusive start and exclusive end ("stop before"!)
		end_at = start_at + octet_length(url);

		-- now that length was calcuated, add https:// if missing
		if url !~ '^https?://' then
			url = 'https://' || url;
		end if;

		objects = array_append(
			objects,
			json_build_object('start', start_at, 'end', end_at, 'url', url)
		);
	end loop;

	return array_to_json(objects);
end;
$$ language plpgsql;

