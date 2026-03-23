-- URIs of the pages that are just templates
-- Each must be in templates table with code ('me-' || uri)

create function me.page_uris() returns setof text as $$
	select unnest(array[
	'a', 'about', 'ai', 'feeds', 'fp', 'h', 'hiring', 'm', 'music',
	'n', 'now', 'privacy', 'sorry', 'thanks', 'ti', 'u', 'uses'
	]);
$$ language sql;
