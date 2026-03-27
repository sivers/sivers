insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-article', 'uri:{{uri}}
posted:{{posted}}
title:{{title}}
mp3:{{mp3}}
mp4:{{mp4}}
book_uri:{{book_uri}}
book_name:{{book_name}}
tag:{{tag}}
body:{{{body}}}
');

insert into articles (id, uri, posted, title, original) values (1, 'one', '2026-01-23', 'The One Thing', '<p>This is the one thing!</p>');
insert into atags (article_id, tag) values (1, 'best');
insert into metabooks (id, uri, name) values (5, 'u', 'Useful Not True');
insert into chapters (metabook_id, article_id) values (5, 1);
insert into audios (id, filename) values (1, 'sive.rs.one.mp3');
insert into videos (id, filename) values (1, 'sive.rs.one.mp4');
insert into media (article, audio) values (1, 1);
insert into media (article, video) values (1, 1);

select plan(1);
select is(body, '<title>The One Thing | Derek Sivers</title><body>uri:one
posted:2026-01-23
title:The One Thing
mp3:sive.rs.one.mp3
mp4:sive.rs.one.mp4
book_uri:u
book_name:Useful Not True
tag:best
body:<p>This is the one thing!</p>
</body>')
from me.article('one');
