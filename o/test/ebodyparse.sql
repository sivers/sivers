insert into people (id, name, greeting, lopass) values (1, 'Person A', 'Peep', 'LoPa');
insert into ats (email, person_id) values ('a@a.com', 1);
insert into ats (email, person_id, used) values ('person@a.net', 1, null);
insert into now_pages (id, person_id, short, long) values (1, 1, 'a.com/now', 'https://a.com/now/');
insert into now_profiles (id, public_id) values (1, 'PuId');
insert into temps(temp, person_id) values ('abcdefghijklmnop', 1);

select plan(2);

select is(
	o.ebodyparse('id={id}, greeting={greeting}, name={name}, lopass={lopass}, temp={temp}, email={email}, public_id={public_id}', 1),
	'id=1, greeting=Peep, name=Person A, lopass=LoPa, temp=abcdefghijklmnop, email=a@a.com or person@a.net, public_id=PuId');

select is(
	o.ebodyparse('short={short}, long={long}', 1),
	'short=a.com/now, long=https://a.com/now/');

