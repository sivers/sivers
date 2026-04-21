insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-article', 'uri:{{uri}}
posted:{{posted}}
title:{{title}}
mp3:{{mp3}}
mp4:{{mp4}}
in_book:{{in_book}}
topic:{{topic}}
topic_name:{{topic_name}}
body:{{{body}}}
');

insert into topics (uri, name, description) values ('u', 'Useful Not True', 'What is true? What is useful?');
insert into articles (id, uri, topic, posted, title, original) values (1, 'one', 'u', '2026-01-23', 'The One Thing', '<p>This is the one thing!</p>');
insert into articles (id, uri, topic, posted, title, original) values (2, 'l8r', 'u', '2026-04-20', 'Later Thing', '<p>Not in book.</p>');
insert into metabooks (id, uri, name) values (5, 'u', 'Useful Not True');
insert into chapters (metabook_id, article_id) values (5, 1);
insert into audios (id, filename) values (1, 'sive.rs.one.mp3');
insert into videos (id, filename) values (1, 'sive.rs.one.mp4');
insert into media (article, audio) values (1, 1);
insert into media (article, video) values (1, 1);

select plan(2);
select is(body, '<title>The One Thing | Derek Sivers</title><body>uri:one
posted:2026-01-23
title:The One Thing
mp3:sive.rs.one.mp3
mp4:sive.rs.one.mp4
in_book:u
topic:u
topic_name:Useful Not True
body:<p>This is the one thing!</p>
</body>')
from me.article('one');

select is(body, '<title>Later Thing | Derek Sivers</title><body>uri:l8r
posted:2026-04-20
title:Later Thing
mp3:
mp4:
in_book:
topic:u
topic_name:Useful Not True
body:<p>Not in book.</p>
</body>')
from me.article('l8r');

