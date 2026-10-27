insert into countries (code, name) values ('NL','Netherlands');
insert into countries (code, name) values ('DE','Germany');

select plan(4);

select is(o.select_country('DE'),
	'[{"code":"DE","show":"Germany","selected":" selected"},{"code":"NL","show":"Netherlands","selected":""}]'::jsonb);

select is(o.select_country('NL'),
	'[{"code":"DE","show":"Germany","selected":""},{"code":"NL","show":"Netherlands","selected":" selected"}]'::jsonb);

select is(o.select_country(''),
	'[{"code":"DE","show":"Germany","selected":""},{"code":"NL","show":"Netherlands","selected":""}]'::jsonb,
	'empty string = show all, none selected');

select is(o.select_country(null),
	'[{"code":"DE","show":"Germany","selected":""},{"code":"NL","show":"Netherlands","selected":""}]'::jsonb,
	'null = show all, none selected');

