-- silly to test, but keeping here for consistency
select plan(1);
select results_eq('select me.page_uris() u order by u',
	array[
	'a', 'about', 'ai', 'feeds', 'fp', 'h', 'hiring', 'm', 'music',
	'n', 'now', 'privacy', 'sorry', 'thanks', 'ti', 'u', 'uses'
	]
);
