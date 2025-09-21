insert into templates (code, template) values ('mynow-headfoot', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-photo', '{{#photo}}<img src="/m/{{public_id}}.webp?{{random_string}}">{{/photo}}{{^photo}}post-photo{{/photo}}');

insert into people (id, name) values (1, 'Has Photo');
insert into now_profiles (id, public_id, photo) values (1, 'PUBi', true);
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

insert into people (id, name) values (2, 'No Photo');
insert into now_profiles (id, public_id, photo) values (2, 'PUBx', false);
insert into logins (cookie, person_id) values ('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 2);

insert into people (id, name) values (3, 'No Profile');
insert into logins (cookie, person_id) values ('cccccccccccccccccccccccccccccccc', 3);

select plan(10);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'no cookie')
from mynow.photo(null);

select is(head, e'303\r\nLocation: /f'),
	is(body, null, 'bad cookie')
from mynow.photo('dddXdddXdddXdddXdddXdddXdddXdddd');

select is(head, e'303\r\nLocation: /f?m=uninvited'),
	is(body, null, 'no profile')
from mynow.photo('cccccccccccccccccccccccccccccccc');

select is(head, null),
	is(body, '<html>post-photo</html>')
from mynow.photo('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

select is(head, null),
	matches(body, '<html><img src="/m/PUBi\.webp\?[A-Za-z0-9]{3}"></html>')
from mynow.photo('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

