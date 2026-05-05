insert into topics (uri, name, description) values ('u', 'u', 'u');
insert into articles (id, uri, topic, posted, title, original) values (1, 'one', 'u', '2026-01-23', 'Test Title', '<p>
	Sentence one.
	Sentence two.
</p><p>
	Sentence three.
</p>');

select plan(2);
select me.article_chop(1);
-- lame tests but mostly random chars returned so too much work to test for randoms
select is(8, length(title_code)) from articles where id = 1;
select is(49, length(template)) from articles where id = 1;
