insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-articles', '<h1>{{howmany}} articles</h1>
{{#topics}}
uri:{{uri}}
name:{{name}}
description:{{description}}
{{/topics}}');
insert into topics (uri, name, description, sortid) values ('test', 'Topic Name', 'second in list', 2);
insert into topics (uri, name, description, sortid) values ('b', 'Book Name', 'third is book topic', 3);
insert into topics (uri, name, description, sortid) values ('a', 'A Topic', 'a description of topic', 1);
insert into articles (uri, topic, original, posted, title) values ('three', 'test', '.', '2026-01-03', 'Title Three');
insert into articles (uri, topic, original, posted, title) values ('four', 'test', '.', '2026-01-04', 'Title Four');

select plan(1);
select is(body, '<title>Derek Sivers articles</title><body><h1>2 articles</h1>
uri:a
name:A Topic
description:a description of topic
uri:test
name:Topic Name
description:second in list
uri:b
name:Book Name
description:third is book topic
</body>')
from me.articles();
