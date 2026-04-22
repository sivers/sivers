-- PostgreSQL unique random defaults, by Derek Sivers. Article: https://sive.rs/rand1

create table things (
  code char(8) primary key default unique_random(8, 'things', 'code'),
  name text
);
