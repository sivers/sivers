select plan(8);

insert into people (id, name) values (1, e' \r \n \t  Clean  \n  Me \r \t');
select is(name, 'Clean Me', 'trig_name_clean insert') from people where id = 1;

update people set name = e' \t Mr.\nClean ' where id = 1;
select is(name, 'Mr. Clean', 'trig_name_clean update') from people where id = 1;

insert into ats (person_id, email) values (1, e' \r \n \t  <AA@AA.cOM> \r \t');
select is(email, 'aa@aa.com', 'trig_email_clean insert') from ats where person_id = 1;

update ats set email = e' \t \n <aAa@aAA.NET> ' where person_id = 1;
select is(email, 'aaa@aaa.net', 'trig_email_clean update') from ats where person_id = 1;

insert into urls (person_id, url) values (1, e' \r \n aa.com \t'); 
select is(url, 'https://aa.com', 'trig_url_clean insert') from urls where person_id = 1;

update urls set url = e' \r \n aa.net \t' where person_id = 1; 
select is(url, 'https://aa.net', 'trig_url_clean update') from urls where person_id = 1;

insert into utags (person_id, tag) values (1, e'\r\n\t " A@B.CoM " \t\r\n'); 
select is(tag, 'abcom', 'trig_utag_clean insert') from utags where person_id = 1;

update utags set tag = e'沈思问 €10 EUR' where person_id = 1; 
select is(tag, 'eur', 'trig_utag_clean update') from utags where person_id = 1;

