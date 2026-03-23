insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-interviews', '<h1>{{howmany}} interviews</h1>
{{#interviews}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
summary:{{summary}}
{{/interviews}}
');

insert into interviews (uri, ymdhm, name, host, summary) values ('2026-01-02-one', '2026-01-02 12:00:00', 'One Show', 'One Host', 'One summary here.');
insert into interviews (uri, ymdhm, name, host, summary) values ('2026-02-03-two', '2026-02-03 12:00:00', 'Two Man', 'Two Man', 'Two man was good.');

select plan(1);
select is(body, '<title>interviews with Derek Sivers</title><body><h1>2 interviews</h1>
date:2026-02-03
uri:2026-02-03-two
title:Two Man
summary:Two man was good.
date:2026-01-02
uri:2026-01-02-one
title:One Show - by One Host
summary:One summary here.
</body>')
from me.interviews();
