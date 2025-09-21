insert into templates (code, template) values ('mynow-headfoot', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-profile1', '<label>{{question}}</label><input code={{code}}><textarea>{{answer}}</textarea><ul>{{#exs}}<li>{{.}}</li>{{/exs}}</ul>');
insert into templates (code, template) values ('mynow-profile', e'<dl>{{#qas}}\n<dt>{{question}}</dt>\n<dd>{{answer}}</dd>\n<a code={{code}}></a>{{/qas}}\n</dl>{{public_id}}');

insert into people (id, name) values (1, 'All Done');
insert into now_profiles (id, public_id, title, liner, why, thought, red) values (1, 'PUBa', 'a title', 'a liner', 'a why', 'a thought', 'a red');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into people (id, name) values (2, 'Half Done');
insert into now_profiles (id, public_id, title, liner) values (2, 'PUBb', 'b title', 'b liner');
insert into logins (cookie, person_id) values ('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 2);

insert into people (id, name) values (3, 'None Done');
insert into now_profiles (id, public_id) values (3, 'PUBc');
insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

select plan(12);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.profile(null, null);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.profile('dddXdddXdddXdddXdddXdddXdddXdddd', null);

select is(head, null, 'none done, ask first question'),
	is(body, '<html><label>Professional title?</label><input code=title><textarea></textarea><ul><li>Freelance web developer</li><li>Director of marketing at Pixar</li><li>Singer/songwriter</li></ul></html>')
from mynow.profile('cccccccccccccccccccccccccccccccc', null);

select is(head, null, 'two done, ask third question'),
	is(body, '<html><label>Why do you do it? (just 1-3 sentences)</label><input code=why><textarea></textarea><ul><li>I write because I have a lot of questions and frustrations to rant about.</li><li>I love to create things out of nothing and care a lot about freedom. Software development is the sweet spot for this.</li></ul></html>')
from mynow.profile('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', null);

select is(head, null, 'all done but pass edit code'),
	is(body, '<html><label>Why do you do it? (just 1-3 sentences)</label><input code=why><textarea>a why</textarea><ul><li>I write because I have a lot of questions and frustrations to rant about.</li><li>I love to create things out of nothing and care a lot about freedom. Software development is the sweet spot for this.</li></ul></html>')
from mynow.profile('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'why');

select is(head, null, 'all done'),
	is(body, '<html><dl>
<dt>Professional title?</dt>
<dd>a title</dd>
<a code=title></a>
<dt>What do you actually do? (in one sentence)</dt>
<dd>a liner</dd>
<a code=liner></a>
<dt>Why do you do it? (just 1-3 sentences)</dt>
<dd>a why</dd>
<a code=why></a>
<dt>Recent thought, epiphany, or interesting idea</dt>
<dd>a thought</dd>
<a code=thought></a>
<dt>Recommended book or article? (title and author)</dt>
<dd>a red</dd>
<a code=red></a>
</dl>PUBa</html>')
from mynow.profile('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', null);

