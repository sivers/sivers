insert into templates (code, template) values ('nnn-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('nnn-about', 'blah blah');
select plan(1);
select is(body, '<title>about nownownow.com</title><body>blah blah</body>')
from nnn.about();
