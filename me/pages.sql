-- URIs and pagetitles of the pages that are just templates
-- Each must be in templates table with code ('me-' || uri)
-- 
-- I could have made these a table in the database, but… eh.

create function me.pages() returns table(uri text, pagetitle text) as $$
	select * from (values
		('a', 'Anything You Want - book by Derek Sivers'),
		('about', 'about Derek Sivers'),
		('ai', 'AI use by Derek Sivers'),
		('feeds', 'Derek Sivers XML RSS feeds'),
		('fp', 'Derek Sivers translated book publishers'),
		('h', 'How to Live - book by Derek Sivers'),
		('hiring', 'Derek Sivers is hiring?'),
		('m', 'Your Music and People - book by Derek Sivers'),
		('music', 'Derek Sivers music'),
		('n', 'Hell Yeah or No - book by Derek Sivers'),
		('now', 'Derek Sivers /now'),
		('privacy', 'privacy notice'),
		('podcast', 'Derek Sivers podcast'),
		('sorry', 'sorry'),
		('thanks', 'thanks'),
		('ti', 'Tech Independence'),
		('u', 'Useful Not True - book by Derek Sivers'),
		('uses', 'Derek Sivers uses')
	);
$$ language sql;
