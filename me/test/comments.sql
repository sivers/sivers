insert into templates (code, template) values ('me-comments', '<ol>
{{#comments}}
<li><cite>{{name}} ({{ymd}})</cite><p>{{{comment}}}</p></li>
{{/comments}}
</ol>');

insert into people (id, name) values (1, 'Past Poster');
insert into people (id, name) values (2, 'New Porker');
insert into articles (uri, posted, title, original) values ('apost', '2026-04-01', 'A Post', '<p>This is a post.</p>');
insert into comments (person_id, uri, created_at, name, email, comment) values (1, 'apost', '2026-01-01', 'Past Poster', 'past@poster.com', 'Past comment.');
insert into comments (person_id, uri, created_at, name, email, comment) values (2, 'apost', '2026-02-02', 'anon', 'new@porker.com', e'Newer comment.\nWith new line.');

select plan(1);
select is(body, '<ol>
<li><cite>Past Poster (2026-01-01)</cite><p>Past comment.</p></li>
<li><cite>anon (2026-02-02)</cite><p>Newer comment.
<br>With new line.</p></li>
</ol>')
from me.comments('apost');
