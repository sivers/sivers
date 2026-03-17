insert into people (id, name) values (1, 'All Done');
insert into now_profiles (id, public_id, title, liner, why, thought, red) values (1, 'PUBa', 'a title', 'a liner', 'a why', 'a thought', 'a red');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);

select plan(8);

select is(head, e'303\r\nLocation: /f', 'nocookie')
	from mynow.profileset(null, 'title', 'new title');

select is(head, e'303\r\nLocation: /f', 'badcookie')
	from mynow.profileset('aaaaaXaaaaaXaaaaXaaaaaXaaaXaaaaa', 'title', 'new title');

select is(title, 'a title', 'did not update yet')
	from now_profiles where id = 1;

select is(head, e'303\r\nLocation: /profile', 'bad key ignored')
	from mynow.profileset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'booboo', 'choo choo');

select is(head, e'303\r\nLocation: /profile', 'update')
	from mynow.profileset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'title', 'new title');

select is(title, 'new title', 'updated')
	from now_profiles where id = 1;

select is(head, e'303\r\nLocation: /profile', 'empty update')
	from mynow.profileset('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'liner', '');

select is(liner, '', 'empty ok')
	from now_profiles where id = 1;

