insert into people (id, name) values (1, 'EE');
insert into people (id, name) values (2, 'DD');
insert into people (id, name) values (3, 'CC');

insert into now_pages (person_id, long) values (1, 'https://ee.com/');
insert into now_pages (person_id, long) values (2, 'https://dd.com/');
insert into now_pages (person_id, long) values (3, 'https://cc.com/');

insert into templates (code, template) values ('nnn-random', '{{{jsurls}}}');

select plan(1);

select is(body, 'const urls = [
"https://cc.com/",
"https://dd.com/",
"https://ee.com/"];', 'sorted')
from nnn.random();

