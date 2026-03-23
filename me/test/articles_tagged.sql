insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-articles', '<h1>{{howmany}} {{tag}} articles</h1>
{{#articles}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
{{/articles}}');
insert into articles (id, uri, posted, title) values (1, 'one', '2026-01-01', 'Title One');
insert into articles (id, uri, posted, title) values (2, 'two', '2026-01-02', 'Title Two');
insert into articles (id, uri, posted, title) values (3, 'three', '2026-01-03', 'Title Three');
insert into articles (id, uri, posted, title) values (4, 'four', '2026-01-04', 'Title Four');
insert into articles (id, uri, posted, title) values (5, 'future', '2099-01-04', 'Future Post');
insert into articles (id, title) values (6, 'Not Yet');

insert into atags (article_id, tag) values (1, 'odd');
insert into atags (article_id, tag) values (2, 'tech');
insert into atags (article_id, tag) values (3, 'odd');
insert into atags (article_id, tag) values (4, 'tech');
insert into atags (article_id, tag) values (5, 'tech');
insert into atags (article_id, tag) values (6, 'tech');

select plan(1);
select is(body, '<title>Derek Sivers tech articles</title><body><h1>2 tech articles</h1>
date:2026-01-04
uri:four
title:Title Four
date:2026-01-02
uri:two
title:Title Two
</body>')
from me.articles_tagged('tech');
