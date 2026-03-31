insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-home', '<h1>tweets</h1>
{{#tweets}}
date:{{ymd}}
tweet:{{tweet}}
{{/tweets}}
');
insert into tweets (time, message) values ('2026-03-01 12:00:00+00', 'Tweet One here: https://one.com/ OK?');
insert into tweets (time, message) values ('2026-03-02 12:00:00+00', 'Tweet Two');

select plan(1);
select is(body, '<title>Derek Sivers</title><body><h1>tweets</h1>
date:2026-03-02
tweet:Tweet Two
date:2026-03-01
tweet:Tweet One here <a href="https://one.com/">one.com/</a> OK?
</body>')
from me.home();
