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
