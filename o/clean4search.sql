-- Why I need to normalize text to be searched:
--
-- My text might have HTML and curly punctuation like:
-- I <strong>won’t</strong> regret it.    ← see the curly apostrophe
--
-- But I want that to be found if someone searches for:
-- I won't regret it    ← see the straight apostrophe
--
-- So I need the same function to clean the indexed text and the search term.
-- And it needs to be immutable strict sql
-- It will remove all <tags> and punctuation, and lowercase while I'm at it.
--
-- USAGE:
--
-- #1 : index all columns to be searched exactly like this:
-- create index on sentences
-- using gin(o.clean4search(sentence) gin_trgm_ops);
--
-- #2 : when searching:
-- select sentence from sentences
-- where o.clean4search(sentence) like '%' || o.clean4search(term) || '%';

-- inside out:
-- 3. lowercase
-- 2. remove not-words not-spaces
-- 1. remove tags
create function o.clean4search(text) returns text as $$
	select lower(regexp_replace(regexp_replace($1, '<[^>]+>', '', 'gi'), '[^\w\s]', '', 'g'));
$$ language sql immutable strict;

