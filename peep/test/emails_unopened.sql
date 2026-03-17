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

insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (1, 2, 'cat1', 0, '2025-10-27', 'two@two.two', 'b', 'subject1', 'body1');
insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (2, 2, 'cat1', 0, '2025-10-28', 'two@two.two', 'b', 'subject2', 'body2');
insert into emails (id, person_id, category, created_by, created_at, opened_at, opened_by, their_email, their_name, subject, body)
values (3, 3, 'cat2', 0, '2025-10-28', now(), 1, 'tri@tri.tri', 'c', 'subject3 is "open"', 'body3 is open');
insert into emails (id, person_id, category, created_by, created_at, their_email, their_name, subject, body)
values (4, 3, 'cat2', 0, '2025-10-29', 'tri@tri.tri', 'c', 'subject4', 'body4');

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-emails', '
<table>
{{#emails}}
<tr>
	<td><a href="/email/{{id}}">{{id}}</a></td>
	<td>{{created_at}}</td>
	<td>{{subject}}</td>
	<td>{{their_name}}</td>
</tr>
{{/emails}}
</table>
');

select plan(6);

select is(head, null),
	is(body, '<html>
<table>
<tr>
	<td><a href="/email/1">1</a></td>
	<td>2025-10-27</td>
	<td>subject1</td>
	<td>b</td>
</tr>
<tr>
	<td><a href="/email/2">2</a></td>
	<td>2025-10-28</td>
	<td>subject2</td>
	<td>b</td>
</tr>
</table>
</html>')
from peep.emails_unopened('cat1');

select is(head, null),
	is(body, '<html>
<table>
<tr>
	<td><a href="/email/4">4</a></td>
	<td>2025-10-29</td>
	<td>subject4</td>
	<td>c</td>
</tr>
</table>
</html>')
from peep.emails_unopened('cat2');

select is(head, null),
	is(body, '<html>
<table>
</table>
</html>')
from peep.emails_unopened('cat9');

