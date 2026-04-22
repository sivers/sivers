-- PostgreSQL triggers for cleaning, by Derek Sivers. Article: https://sive.rs/clean1

insert into people (name, code) values (e' \t \r \n Dr.  \n \r JM \t Lim \r\n', '   XX o Z ') returning *;
-- id │    name    │ code 
--────┼────────────┼──────
--  1 │ Dr. JM Lim │ xxoz

insert into emails (person_id, email) values (1, e' \r\n \t DR. L @ JM Lim . com \n') returning *;
-- id │ person_id │     email      
--────┼───────────┼────────────────
--  1 │         1 │ dr.l@jmlim.com

