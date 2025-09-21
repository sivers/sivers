insert into templates (code, template) values ('mynow-headfoot', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-urls', '<ul>{{#urls}}<li>{{id}} {{#main}}<strong>{{/main}}{{url}}{{#main}}</strong>{{/main}}</li>{{/urls}}</ul>');

insert into people (id, name) values (1, 'Person A');
insert into people (id, name) values (2, 'Person B');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into urls (id, person_id, url, main) values (1, 1, 'https://x.com/a', false);
insert into urls (id, person_id, url, main) values (2, 1, 'https://a.com/', true);
insert into urls (id, person_id, url, main) values (3, 2, 'https://not-their-url.com', false);
insert into urls (id, person_id, url, main) values (4, 1, 'https://aaa.net/', false);

select plan(6);

select is(head, e'303\r\nLocation: /f', 'nocookie'),
	is(body, null)
from mynow.urls(null);

select is(head, e'303\r\nLocation: /f', 'badcookie'),
	is(body, null)
from mynow.urls('aaaXaaaXaaaXaaaXaaaXaaaaaaaaXaaa');

select is(head, null, 'good'),
	is(body, '<html><ul><li>2 <strong>https://a.com/</strong></li><li>1 https://x.com/a</li><li>4 https://aaa.net/</li></ul></html>')
from mynow.urls('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

