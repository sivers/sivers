insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-ref', '<h1>{{howmany}} books</h1>
{{#books}}
uri:{{uri}}
title:{{title}}
refsme:{{refsme}}
{{/books}}
');
insert into ebooks (code, title, author, refsme) values ('BookEight', 'Book Eight', 'Eight Author', 'Something about me but longer so comes later.');
insert into ebooks (code, title, author, refsme) values ('BookSeven', 'Book Seven', 'Great Author', 'Shorter quotes first.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Book Nine', 'Nine Author', 1, '2026-02-09', 'should not appear here');

select plan(1);
select is(body, '<title>books that reference Derek Sivers</title><body><h1>2 books</h1>
uri:BookSeven
title:Book Seven - by Great Author
refsme:Shorter quotes first.
uri:BookEight
title:Book Eight - by Eight Author
refsme:Something about me but longer so comes later.
</body>')
from me.ref();
