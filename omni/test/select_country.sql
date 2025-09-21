insert into countries (code, name) values ('NL','Netherlands');
insert into countries (code, name) values ('DE','Germany');

select plan(4);

select is(o.select_country('DE'),
	'[{"code":"DE","name":"Germany","selected":" selected"},{"code":"NL","name":"Netherlands","selected":""}]'::jsonb);

select is(o.select_country('NL'),
	'[{"code":"DE","name":"Germany","selected":""},{"code":"NL","name":"Netherlands","selected":" selected"}]'::jsonb);

select is(o.select_country(''),
	'[{"code":"DE","name":"Germany","selected":""},{"code":"NL","name":"Netherlands","selected":""}]'::jsonb,
	'empty string = show all, none selected');

select is(o.select_country(null),
	'[{"code":"DE","name":"Germany","selected":""},{"code":"NL","name":"Netherlands","selected":""}]'::jsonb,
	'null = show all, none selected');

