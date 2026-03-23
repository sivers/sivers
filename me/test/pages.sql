-- silly to test static values, but keeping here for consistency
select plan(1);
select results_eq('select uri from me.pages() order by uri',
	array[
	'a', 'about', 'ai', 'feeds', 'fp', 'h', 'hiring', 'm', 'music',
	'n', 'now', 'privacy', 'sorry', 'thanks', 'ti', 'u', 'uses'
	]
);
