insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-search', '<h1>search for {{term}}</h1>
just:{{just}}
{{#results}}
uri:{{uri}}
show:{{{show}}}
{{/results}}
{{^results}}
no results
{{/results}}
');
insert into metabooks (uri, name) values ('b', 'A Book About Pigs');
insert into metabooks (uri, name) values ('z', 'Birds not found');
insert into topics (uri, name, description, sortid) values ('test', 'Topic Name', 'BIGPIGS are mentioned in description', 2);
insert into topics (uri, name, description, sortid) values ('b', 'A Book About Pigs', 'should not appear in search, since book', 3);
insert into topics (uri, name, description, sortid) values ('a', 'Pigskin', 'not a book', 1);
insert into tweets (id, time, message) values (1234, '2026-03-01 12:00:00+00', 'No pigs would come here.');
insert into tweets (id, time, message) values (1235, '2026-03-02 12:00:00+00', 'A wolf built my house');
insert into ebooks (code, title, author, rating, read, summary) values ('BookEight', 'The Pig Did it', 'Eight Author', 8, '2026-02-08', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookNine', 'Praise Swine', 'Donald', 8, '2026-02-09', 'A pig might like this book.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookTen', 'Feed Me', 'Lucy the Pig', 8, '2026-02-10', '.');
insert into ebooks (code, title, author, rating, read, summary) values ('BookSeven', 'Ducks', 'Duckling', 5, '2026-02-07', '.');
insert into ebooknotes (ebook_code, sortid, note) values ('BookSeven', 1, 'What do ducks like?');
insert into ebooknotes (ebook_code, sortid, note) values ('BookSeven', 2, 'Ducks like epigrams.');
insert into articles (id, uri, posted, topic, title, original) values (1, 'article1', '2026-01-01', 'a', 'Title of Piggy Article One', '.');
insert into articles (id, uri, posted, topic, title, original) values (2, 'article2', '2026-02-02', 'b', 'How to Raise Them', '.');
insert into sentences (article_id, sortid, sentence) values (1, null, 'Title of Piggy Article One');
insert into sentences (article_id, sortid, sentence) values (1, 1, 'First sentence of article1.');
insert into sentences (article_id, sortid, sentence) values (1, 2, 'Second sentence mentions pigs.');
insert into sentences (article_id, sortid, sentence) values (1, 3, 'Third sentence does not.');
insert into sentences (article_id, sortid, sentence) values (2, null, 'How to Raise Them');
insert into sentences (article_id, sortid, sentence) values (2, 1, 'So you want to know?');
insert into sentences (article_id, sortid, sentence) values (2, 2, 'How to raise them?');
insert into sentences (article_id, sortid, sentence) values (2, 3, 'Starting as piglets, of course.');
insert into presentations (uri, title, description, month, transcript) values ('prez1', 'One Presentation', 'The description of one.', '2026-01', e'This first line should not show.\n\nThis transcript has a brief mention of a pig.\n\nThis last line should not show.');
insert into presentations (uri, title, description, month, transcript) values ('prez2', 'Pig Presentation', 'The description of two.', '2026-02', 'Transcript also mentions pigs, but since title hit already, ideally this should not show twice, but will for now.');
insert into meetwheres (id, display, thoughts) values (1, 'Pigville', 'Stinks.');
insert into meetwheres (id, display, thoughts) values (2, 'Hog Town', 'Do not call it Pig Town. They hate that.');
insert into people (id, name) values (1, 'Person One');
insert into people (id, name) values (2, 'Little Piggy');
insert into meetings (id, where_id, person_id, topics, notes) values (10, 1, 1, 'Pigville and mud', 'notes not searched.');
insert into meetings (id, where_id, person_id, topics, notes) values (11, 2, 2, '.', '.');
insert into interviews (id, uri, person_id, ymdhm, name, host, summary) values (1, 'i1', 1, '2026-01-01 01:01:01', 'Muddy Pit', 'Person One', 'Dirty talk.');
insert into interviews (id, uri, person_id, ymdhm, name, host, summary) values (2, 'i2', 2, '2026-02-02 02:02:02', 'Little Talk', 'Little Piggy', '.');
insert into utterances (interview_id, seconds, utype, speaker, content) values (1, 10, 'question', 'Person One', 'My question about pigs will not appear?');
insert into utterances (interview_id, seconds, utype, speaker, content) values (1, 20, 'answer', 'sivers', 'Yep. Search only returns my pig parts.');
insert into utterances (interview_id, seconds, utype, speaker, content) values (2, 10, 'question', 'Little Piggy', 'How ya been?');
insert into utterances (interview_id, seconds, utype, speaker, content) values (2, 20, 'answer', 'sivers', 'Muddy');
 
select plan(6);

select is(body, '<title>search Derek Sivers site</title><body><h1>search for xxx</h1>
just:
no results
</body>')
from me.search('xxx', 'zzz');

select is(body, '<title>search Derek Sivers site</title><body><h1>search for xxx</h1>
just:articles
no results
</body>')
from me.search('xxx', 'articles');

select is(body, '<title>search Derek Sivers site</title><body><h1>search for pig</h1>
just:
uri:b
show:a book about <strong>pig</strong>s
uri:article1
show:title of <strong>pig</strong>gy article one
uri:i2
show:little <strong>pig</strong>gy
uri:prez2
show:<strong>pig</strong> presentation
uri:met/at-1
show:<strong>pig</strong>ville
uri:met/11
show:little <strong>pig</strong>gy
uri:article1
show:second sentence mentions <strong>pig</strong>s
uri:article2
show:starting as <strong>pig</strong>lets of course
uri:prez1
show:this transcript has a brief mention of a <strong>pig</strong>
uri:prez2
show:transcript also mentions <strong>pig</strong>s but since title hit already ideally this should not show twice but will for now
uri:met/at-2
show:do not call it <strong>pig</strong> town they hate that
uri:met/at-10
show:<strong>pig</strong>ville and mud
uri:i1
show:yep search only returns my <strong>pig</strong> parts
uri:book/BookEight
show:the <strong>pig</strong> did it
uri:book/BookTen
show:lucy the <strong>pig</strong>
uri:book/BookNine
show:a <strong>pig</strong> might like this book
uri:book/BookSeven
show:ducks like e<strong>pig</strong>rams
</body>')
from me.search(' "PIG" ', '');

select is(body, '<title>search Derek Sivers site</title><body><h1>search for pig</h1>
just:articles
uri:article1
show:title of <strong>pig</strong>gy article one
uri:article1
show:second sentence mentions <strong>pig</strong>s
uri:article2
show:starting as <strong>pig</strong>lets of course
</body>')
from me.search(' <alert>pIg</alert> ', 'articles');

select is(body, '<title>search Derek Sivers site</title><body><h1>search for pig</h1>
just:books
uri:book/BookEight
show:the <strong>pig</strong> did it
uri:book/BookTen
show:lucy the <strong>pig</strong>
uri:book/BookNine
show:a <strong>pig</strong> might like this book
uri:book/BookSeven
show:ducks like e<strong>pig</strong>rams
</body>')
from me.search('pig', 'books');

select is(body, '<title>search Derek Sivers site</title><body><h1>search for pig</h1>
just:interviews
uri:i2
show:little <strong>pig</strong>gy
uri:i1
show:yep search only returns my <strong>pig</strong> parts
</body>')
from me.search('pi’g', 'interviews');


