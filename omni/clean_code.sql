-- use to make text just lowercase a-z, no punctuation or whitespace
create function o.clean_code(text) returns text as $$
	select regexp_replace(lower($1 collate "C"), '[^a-z]+', '', 'g');
$$ language sql immutable strict parallel safe;
