insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-home', '<h1>articles</h1>
{{#articles}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
{{/articles}}

<h1>tweets</h1>
{{#tweets}}
date:{{ymd}}
tweet:{{tweet}}
{{/tweets}}

<h1>books</h1>
{{#books}}
date:{{ymd}}
uri:{{uri}}
title:{{title}}
{{/books}}
');
insert into articles (uri, posted, title) values ('three', '2026-01-03', 'Title Three');
insert into articles (uri, posted, title) values ('four', '2026-01-04', 'Title Four');
insert into tweets (time, message) values ('2026-03-01 12:00:00+00', 'Tweet One');
insert into tweets (time, message) values ('2026-03-02 12:00:00+00', 'Tweet Two');
insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '2026-02-08', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 8, '2026-02-09', '.');

select plan(1);
select is(body, '<title>Derek Sivers</title><body><h1>articles</h1>
date:2026-01-04
uri:four
title:Title Four
date:2026-01-03
uri:three
title:Title Three

<h1>tweets</h1>
date:2026-03-02
tweet:Tweet Two
date:2026-03-01
tweet:Tweet One

<h1>books</h1>
date:2026-02-09
uri:BookNine
title:Book Nine - by Nine Author
date:2026-02-08
uri:BookEight
title:Book Eight - by Eight Author
</body>')
from me.home();
