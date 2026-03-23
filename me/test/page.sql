insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-cat', 'static page about cats');
insert into templates (code, template) values ('me-dog', 'dogs have a static page too');

select plan(2);

select is(body, '<title>cats rule</title><body>static page about cats</body>')
from me.page('cat', 'cats rule');

select is(body, '<title>dogs drool</title><body>dogs have a static page too</body>')
from me.page('dog', 'dogs drool');

