insert into templates(code, template) values ('body', '{{#person}}<h1>{{name}}</h1>{{/person}}');
insert into templates(code, template) values ('wrap', '<html><head><title>{{pagetitle}}</title></head><body>{{{core}}}</body></html>');
insert into templates(code, template) values ('list', '<ul>{{#things}}<li>{{thing}}</li>{{/things}}</ul>');
insert into templates(code, template) values ('listdot', '<ul>{{#things}}<li>{{.}}</li>{{/things}}</ul>');
insert into templates(code, template) values ('unescaped', '{{{somejs}}}');
insert into templates(code, template) values ('novarwrap', '<html>{{{core}}}</html>');
insert into templates(code, template) values ('novarbody', '<body>ok</body>');

select plan(9);

select is('<h1>Derek</h1>',
	o.template('body',
		'{"person":{"name":"Derek"}}'::jsonb), 'basic');

select is('<ul><li>a</li><li>b</li></ul>',
	o.template('list',
		'{"things":[{"thing":"a"},{"thing":"b"}]}'::jsonb), 'list');

select is('<html><head><title>TEST</title></head><body><h1>Derek</h1></body></html>',
	o.template('wrap', 'body',
		'{"pagetitle":"TEST","person":{"name":"Derek"}}'::jsonb), 'wrap');

select is('<html><head><title>LISTTEST</title></head><body><ul><li>a</li><li>b</li></ul></body></html>',
	o.template('wrap', 'list',
		'{"pagetitle":"LISTTEST", "things":[{"thing":"a"},{"thing":"b"}]}'::jsonb), 'listwrap');

select is('<html><head><title>LISTTEST</title></head><body><ul><li>a</li><li>b</li></ul></body></html>',
	o.template('wrap', 'listdot',
		'{"pagetitle":"LISTTEST", "things":["a","b"]}'::jsonb), 'listwrap2');

select is($$<html><head><title>UNESCD</title></head><body><script>const hi = 'hello';</script></body></html>$$,
	o.template('wrap', 'unescaped',
		$${"pagetitle":"UNESCD", "somejs":"<script>const hi = 'hello';</script>"}$$::jsonb), 'double-unescaped');

-- ugly but possible to merge templates and also wrap them!
-- just put the concatted parsed text as the "core" value inside the final jsonb
select is('<html><head><title>TEST</title></head><body><h1>Derek</h1><ul><li>a</li><li>b</li></ul></body></html>',
	o.template('wrap', jsonb_build_object('pagetitle', 'TEST', 'core',
		o.template('body', '{"person":{"name":"Derek"}}'::jsonb) ||
		o.template('list', '{"things":[{"thing":"a"},{"thing":"b"}]}'::jsonb))), 'merge and wrap');

select is('<body>ok</body>', 
	o.template('novarbody', null), 'null OK as JSONB');

select is('<html><body>ok</body></html>', 
	o.template('novarwrap', 'novarbody', null), 'wrap null OK as JSONB');

