insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-topic', '<h1>{{name}}</h1>
description:{{description}}
howmany:{{howmany}}
{{#articles}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
{{/articles}}');
insert into topics (uri, name, description) values ('test', 'Topic Name', 'description of topic');
insert into topics (uri, name, description) values ('no', 'unused', 'do not show');
insert into articles (uri, topic, original, posted, title) values ('three', 'test', '.', '2026-01-03', 'Title Three');
insert into articles (uri, topic, original, posted, title) values ('four', 'test', '.', '2026-01-04', 'Title Four');
insert into articles (uri, topic, original, posted, title) values ('five', 'no', '.', '2026-04-04', 'not shown here');

select plan(1);
select is(body, '<title>Derek Sivers Topic Name articles</title><body><h1>Topic Name</h1>
description:description of topic
howmany:2
date:2026-01-04
uri:four
title:Title Four
date:2026-01-03
uri:three
title:Title Three
</body>')
from me.topic_page('test');
