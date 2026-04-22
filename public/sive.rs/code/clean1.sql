-- PostgreSQL triggers for cleaning, by Derek Sivers. Article: https://sive.rs/clean1

create table people (
  id serial primary key,
  name text,
  code text
);

create table emails (
  id serial primary key,
  person_id integer not null references people(id),
  email text
);

-- remove all whitespace, then lowercase it
create function lower_no_space(text) returns text as $$
  select lower(regexp_replace($1, '\s', '', 'g'));
$$ language sql;

-- replace all whitespace with single space, then trim start and end
create function no_extra_space(text) returns text as $$
  select btrim(regexp_replace($1, '\s+', ' ', 'g'));
$$ language sql;

create function clean_people() returns trigger as $$
begin
  new.name = no_extra_space(new.name);
  new.code = lower_no_space(new.code);
  return new;
end;
$$ language plpgsql;
create trigger clean_people
before insert or update on people
for each row execute procedure clean_people();

create function clean_emails() returns trigger as $$
begin
  new.email = lower_no_space(new.email);
  return new;
end;
$$ language plpgsql;
create trigger clean_emails
before insert or update on emails
for each row execute procedure clean_emails();

insert into people (name, code) values (e' \t \r \n Dr.  \n \r JM \t Lim \r\n', '   AB c D ') returning *;
-- id │    name    │ code 
--────┼────────────┼──────
--  1 │ Dr. JM Lim │ abcd

insert into emails (person_id, email) values (1, e' \r\n \t DR. L @ JM Lim . com \n') returning *;
-- id │ person_id │     email      
--────┼───────────┼────────────────
--  1 │         1 │ dr.l@jmlim.com

