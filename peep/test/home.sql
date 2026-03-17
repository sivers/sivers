insert into people (id, name) values (0, 'bot');
insert into people (id, name) values (1, 'a');
insert into people (id, name) values (2, 'b');
insert into people (id, name) values (3, 'c');

insert into ats (person_id, email) values (1, 'one@one.one');
insert into ats (person_id, email) values (2, 'two@two.two');
insert into ats (person_id, email) values (3, 'tri@tri.tri');

insert into admins (person_id) values (1);
insert into admin_auths (person_id, appcode) values (1, 'peep');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into emails (id, person_id, category, created_by, their_email, their_name, subject, body)
values (1, 2, 'cat1', 0, 'two@two.two', 'b', 'subject1', 'body1');
insert into emails (id, person_id, category, created_by, their_email, their_name, subject, body)
values (2, 2, 'cat1', 0, 'two@two.two', 'b', 'subject2', 'body2');
insert into emails (id, person_id, category, created_by, opened_at, opened_by, their_email, their_name, subject, body)
values (3, 3, 'cat2', 0, now() - interval '18.5 seconds', 1, 'tri@tri.tri', 'c', 'subject3 is "open"', 'body3 is open');
insert into emails (id, person_id, category, created_by, their_email, their_name, subject, body)
values (4, 3, 'cat2', 0, 'tri@tri.tri', 'c', 'subject4', 'body4');

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-home', '{{#unopened}}
<h1>unopened</h1>
<table>
{{#unopened}}
<tr>
	<td><a href="/next/{{category}}">{{category}}</a></td>
	<td><a href="/list/{{category}}">{{count}}</a></td>
</tr>
{{/unopened}}
</table>
{{/unopened}}

{{#open}}
<h1>open</h1>
<ul>
{{#open}}
<li>
	<a href="/email/{{id}}">{{subject}}</a>
	— age {{age}} by {{by}}
</li>
{{/open}}
</ul>
{{/open}}');

select plan(6);

select is(head, null),
	is(body, '<html><h1>unopened</h1>
<table>
<tr>
	<td><a href="/next/cat1">cat1</a></td>
	<td><a href="/list/cat1">2</a></td>
</tr>
<tr>
	<td><a href="/next/cat2">cat2</a></td>
	<td><a href="/list/cat2">1</a></td>
</tr>
</table>

<h1>open</h1>
<ul>
<li>
	<a href="/email/3">subject3 is &quot;open&quot;</a>
	— age 00:00:18 by a
</li>
</ul>
</html>')
from peep.home();

update emails set closed_at = now(), closed_by = 1 where id = 3;

select is(head, null, 'notice the open section is gone'),
	is(body, '<html><h1>unopened</h1>
<table>
<tr>
	<td><a href="/next/cat1">cat1</a></td>
	<td><a href="/list/cat1">2</a></td>
</tr>
<tr>
	<td><a href="/next/cat2">cat2</a></td>
	<td><a href="/list/cat2">1</a></td>
</tr>
</table>

</html>')
from peep.home();

update emails set opened_at = now(), opened_by = 1, closed_at = now(), closed_by = 1 where id in (1, 2, 4);

select is(head, null, 'notice the unopened section is gone'),
	is(body, '<html>
</html>')
from peep.home();

