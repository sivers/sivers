insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-book', 'code:{{code}}
title:{{title}}
author:{{author}}
isbn:{{isbn}}
read:{{read}}
rating:{{rating}}
summary:{{summary}}
notes:{{{notes}}}
');

insert into ebooks (code, title, author, rating, isbn, read, summary) values ('BookEight', 'Book Eight', 'Eight Author', 8, '9781234567', '2026-02-08', 'A “summary” of book eight.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookEight', 2, e'2nd paragraph.\nCan have "separate" lines.\nLike this.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookEight', 1, '1st paragraph.');

select plan(1);
select is(body, '<title>Book Eight - by Eight Author | Derek Sivers</title><body>code:BookEight
title:Book Eight
author:Eight Author
isbn:9781234567
read:2026-02-08
rating:8
summary:A “summary” of book eight.
notes:
<p>1st paragraph.</p>
<p>2nd paragraph.
Can have &quot;separate&quot; lines.
Like this.</p>
</body>')
from me.book('BookEight');
