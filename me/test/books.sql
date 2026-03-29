insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-books', '<h1>{{howmany}} books</h1>
{{#books}}
date:{{read}}
uri:{{uri}}
title:{{title}}
rating:{{rating}}
summary:{{summary}}
{{/books}}
');
insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '2026-02-08', 'A “summary” of book eight.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 1, '2026-02-09', 'Don’t expect much from nine.');

select plan(1);
select is(body, '<title>book notes by Derek Sivers</title><body><h1>2 books</h1>
date:2026-02-09
uri:BookNine
title:Book Nine - by Nine Author
rating:1
summary:Don’t expect much from nine.
date:2026-02-08
uri:BookEight
title:Book Eight - by Eight Author
rating:8
summary:A “summary” of book eight.
</body>')
from me.books();
