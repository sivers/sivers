insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-articles', '<h1>{{howmany}} articles</h1>
{{#articles}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
{{/articles}}');
insert into articles (uri, posted, title) values ('three', '2026-01-03', 'Title Three');
insert into articles (uri, posted, title) values ('four', '2026-01-04', 'Title Four');

select plan(1);
select is(body, '<title>Derek Sivers articles</title><body><h1>2 articles</h1>
date:2026-01-04
uri:four
title:Title Four
date:2026-01-03
uri:three
title:Title Three
</body>')
from me.articles();
