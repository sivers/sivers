insert into templates (code, template) values ('nnn-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('nnn-now', '<script></script>');
select plan(1);
select is(body, '<title>nownownow.com is doing what, now?</title><body><script></script></body>')
from nnn.now();
