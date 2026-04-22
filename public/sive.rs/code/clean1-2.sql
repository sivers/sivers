-- PostgreSQL triggers for cleaning, by Derek Sivers. Article: https://sive.rs/clean1

-- remove all whitespace, then lowercase it
create function lower_no_space(text) returns text as $$
  select lower(regexp_replace($1, '\s', '', 'g'));
$$ language sql;

-- replace all whitespace with single space, then trim start and end
create function no_extra_space(text) returns text as $$
  select btrim(regexp_replace($1, '\s+', ' ', 'g'));
$$ language sql;
