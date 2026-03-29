-- ebooks table has books not meant for the sive.rs site
-- (I enter books into this database before reading them.)
-- 
-- This returns the URIs of the books that are ready to post.
-- 
-- Kept as a separate function for two reasons:
-- 
-- 1. Some pages (books, home) need to select them all, but
-- 2. The site-making script needs to loop through the URIs to output.
--
-- ... so it's better if both of these are referring to the exact same URIs.

create function me.book_uris() returns table(uri text) as $$
	select code from ebooks
	where read is not null
	and rating is not null
	and summary is not null
$$ language sql;
