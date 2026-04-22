-- PostgreSQL unique random defaults, by Derek Sivers. Article: https://sive.rs/rand1

create table cookies (
  person_id int primary key,
  cookie char(32) unique default unique_random(32, 'cookies', 'cookie')
);
