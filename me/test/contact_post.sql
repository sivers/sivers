-- necessary for outgoing emails:
insert into people (id, name) values (0, 'robot');
insert into configs (k, v) values ('sig', 'signing off');

insert into countries (code, name) values ('GB','United Kingdom');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into ips (range, country, state, city) values ('[16843008,16843264)', 'GB', 'ENG', 'Oxford'); -- 1.1.1.1
insert into formletters (id, title, subject, body) values (1, '_/contact', 'sive.rs', e'Thanks for doing https://sive.rs/contact\n\nPlease reply to this email now.\n\nYou are in my contacts now, white-listed in my system, to make sure I see your reply.\n\nPlease add me to your contacts too, to make sure you see mine.\n\nI always reply within a few days.');

insert into templates (code, template) values ('me-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('me-contactpost', 'Thanks {{name}} check {{email}}');

select setval('people_id_seq', 1);
select setval('emails_id_seq', 1);

select plan(21);
select is(count(*)::integer, 0, 'no emails') from emails;

select is(head, null, '200'),
	is(body, '<html>Thanks Willy Wonka check willy@wonka.com</html>', 'thanks body')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', '  Willy Wonka',
	'email', 'WILLY@WONKA.COM',
	'country', 'GB',
	'city', e' Oxford\r\n',
	'state', 'ENG',
	'sivers', 'sivers',
	'url', ''));

select is(count(*)::integer, 1, 'one email') from emails;

select is(name, 'Willy Wonka', 'name'),
	is(city, 'Oxford', 'city'),
	is(state, 'ENG', 'state'),
	is(country, 'GB', 'country'),
	is(ats.email, 'willy@wonka.com', 'ats.email')
from people join ats on people.id = ats.person_id where people.id = 2;

select is(subject, 'sive.rs'),
	is(their_email, 'willy@wonka.com'),
	is(their_name, 'Willy Wonka'),
	is(person_id, 2),
	is(outgoing, null),
	alike(body, 'Hi Willy%', 'body')
from emails where id = 2;

-- Now let's do some bad ones:
select is(head, e'303\r\nLocation: /thanks', 'fail country')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'Willy Wonka',
	'email', 'willy@wonka.com',
	'country', 'XX',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', ' S.ivE.RS',
	'url', ''));

select is(head, e'303\r\nLocation: /thanks', 'url exists')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'Willy Wonka',
	'email', 'willy@wonka.com',
	'country', 'GB',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', 'sivers',
	'url', 'https://wonka.com'));

select is(head, e'303\r\nLocation: /thanks', 'name is test')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'test',
	'email', 'willy@wonka.com',
	'country', 'GB',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', 'sivers'));

select is(head, e'303\r\nLocation: /thanks', 'test@ email')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'Willy Wonka',
	'email', 'test@wonka.com',
	'country', 'GB',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', 'Sive.rs'));

select is(head, e'303\r\nLocation: /thanks', '@example email')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'Willy Wonka',
	'email', 'willy@example.com',
	'country', 'GB',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', 'Sive.rs'));

select is(head, e'303\r\nLocation: /contact', 'fail sivers')
from me.contact_post(jsonb_build_object(
	'ip', '1.1.1.1',
	'name', 'Willy Wonka',
	'email', 'willy@wonka.com',
	'country', 'GB',
	'city', 'Oxford',
	'state', 'ENG',
	'sivers', 'derek'));

