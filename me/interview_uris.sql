-- interviews table has interviews not meant for the sive.rs site
-- (future interviews scheduled, or that aren't public yet)
-- 
-- This returns the URIs of the interviews that are ready to post.
-- 
-- Kept as a separate function for two reasons:
-- 
-- 1. Some pages (interviews, home) need to select them all, but
-- 2. The site-making script needs to loop through the URIs to output.
--
-- ... so it's better if both of these are referring to the exact same URIs.

create function me.interview_uris() returns setof text as $$
	select uri from interviews
	where uri is not null and summary is not null
$$ language sql;
