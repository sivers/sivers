insert into videos (id, filename, seconds) values (1, 'one.mp4', 111);
insert into videos (id, filename, seconds) values (2, 'two.mp4', 222);
insert into videos (id, filename, seconds) values (3, 'tree.mp4', 33);

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-video-list', '{{#videos}}
<li><a href="/vt/{{id}}">{{filename}}</a></li>
{{/videos}}');

select plan(2);

select is(head, null),
	is(body, '<html><li><a href="/vt/1">one.mp4</a></li>
<li><a href="/vt/2">two.mp4</a></li>
<li><a href="/vt/3">tree.mp4</a></li>
</html>')
from peep.videotext_list();

