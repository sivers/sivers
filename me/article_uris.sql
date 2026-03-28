-- articles table may contain articles not meant for the sive.rs site
-- (for example: chapters of a book that's not yet released)
-- 
-- This returns the URIs of the articles that are ready to post.
--
-- Kept as a separate function for two reasons:
-- 
-- 1. Some pages (articles, home) need to select them all, but
-- 2. The site-making script needs to loop through the URIs to output.
--
-- ... so it's better if both of these are referring to the exact same URIs.

create function me.article_uris() returns table(uri text) as $$
	select uri from articles
	where posted is not null and posted <= now()
$$ language sql;
