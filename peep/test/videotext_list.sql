insert into videos (id, name, seconds) values (1, 'one', 111);
insert into videos (id, name, seconds) values (2, 'two', 222);
insert into videos (id, name, seconds) values (3, 'tree', 33);

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-video-list', '{{#videos}}
<li><a href="/vt/{{id}}">{{name}}</a></li>
{{/videos}}');

select plan(2);

select is(head, null),
	is(body, '<html><li><a href="/vt/1">one</a></li>
<li><a href="/vt/2">two</a></li>
<li><a href="/vt/3">tree</a></li>
</html>')
from peep.videotext_list();

