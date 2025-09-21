select plan(55);

select is(o.mash_template('{{#person}}{{name}}{{/person}}', '[{"person":{"name":"Derek"}}]'::jsonb), 'Derek');
select is(o.mash_template('{{#person}}{{name}}{{/person}}', '{"person":{"name":"Derek"}}'::jsonb), 'Derek');

--- Mustache spec: (not all of it)

-- Triple Mustache Context Miss Interpolation
select is(
	o.mash_template('"I ({{{cannot}}}) be seen!"', '{}'::jsonb),
	'"I () be seen!"',
	'Failed context lookups should default to empty strings.');

-- Context
select is(
	o.mash_template('"{{#context}}Hi {{name}}.{{/context}}"', '{"context":{"name":"Joe"}}'::jsonb),
	'"Hi Joe."',
	'Objects and hashes should be pushed onto the context stack.');

-- Parent contexts
select is(
	o.mash_template('"{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}"', '{"a":"foo","b":"wrong","sec":{"b":"bar"},"c":{"d":"baz"}}'::jsonb),
	'"foo, bar, baz"',
	'Names missing in the current context are looked up in the stack.');

-- Variable test
select is(
	o.mash_template('"{{#foo}}{{.}} is {{foo}}{{/foo}}"', '{"foo":"bar"}'::jsonb),
	'"bar is bar"',
	'Non-false sections have their value at the top of context, accessible as {{.}} or through the parent context. This gives a simple way to display content conditionally if a variable exists.');

-- List Contexts
select is(
	o.mash_template('{{#tops}}{{#middles}}{{tname.lower}}{{mname}}.{{#bottoms}}{{tname.upper}}{{mname}}{{bname}}.{{/bottoms}}{{/middles}}{{/tops}}',
		'{"tops":[{"tname":{"upper":"A","lower":"a"},"middles":[{"mname":"1","bottoms":[{"bname":"x"},{"bname":"y"}]}]}]}'::jsonb),
	'a1.A1x.A1y.',
	'All elements on the context stack should be accessible within lists.');

-- Truthy sections
select is(
	o.mash_template('"{{#boolean}}This should be rendered.{{/boolean}}"', '{"boolean":true}'::jsonb),
	'"This should be rendered."',
	'Truthy sections should have their contents rendered.');

-- Falsey sections
select is(
	o.mash_template('"{{#boolean}}This should not be rendered.{{/boolean}}"', '{"boolean":false}'::jsonb),
	'""',
	'Falsey sections should have their contents omitted.');

-- Null is falsey.
select is(
	o.mash_template('"{{#null}}This should not be rendered.{{/null}}"', '{"null":null}'::jsonb),
	'""',
	'null is falsey');

-- Surrounding Whitespace
select is(
	o.mash_template(e' | {{^boolean}}\t|\t{{/boolean}} | \n', '{"boolean":false}'::jsonb),
	e' | \t|\t | \n',
	'Inverted sections should not alter surrounding whitespace.');

-- Internal Whitespace
select is(
	o.mash_template(e' | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n', '{"boolean":false}'::jsonb),
	e' |  \n  | \n',
	'Inverted should not alter internal whitespace.');

-- Indented Inline Sections
select is(
	o.mash_template(e' {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n', '{"boolean":false}'::jsonb),
	e' NO\n WAY\n',
	'Single-line sections should not alter surrounding whitespace.');

-- Standalone Lines
select is(
	o.mash_template(e'|\n\t| This Is\n\t{{^boolean}}\n\t|\n\t{{/boolean}}\n\t| A Line', '{"boolean":false}'::jsonb),
	e'|\n\t| This Is\n\t|\n\t| A Line',
	'Standalone lines should be removed from the template.');

-- Standalone Indented Lines
select is(
	o.mash_template(e'|\n\t| This Is\n\t  {{^boolean}}\n\t|\n\t  {{/boolean}}\n\t| A Line', '{"boolean":false}'::jsonb),
	e'|\n\t| This Is\n\t|\n\t| A Line',
	'Standalone indented lines should be removed from the template.');

-- Standalone Line Endings
select is(
	o.mash_template(e'|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|', '{"boolean":false}'::jsonb),
	e'|\r\n|',
	'"\r\n" should be considered a newline for standalone tags.');

-- Standalone Without Previous Line
select is(
	o.mash_template(e'  {{^boolean}}\n^{{/boolean}}\n/', '{"boolean":false}'::jsonb),
	e'^\n/',
	'Standalone tags should not require a newline to precede them.');

-- Standalone Without Newline
select is(
	o.mash_template(e'^{{^boolean}}\n/\n  {{/boolean}}', '{"boolean":false}'::jsonb),
	e'^\n/\n',
	'Standalone tags should not require a newline to follow them.');

-- Dotted Names - Truthy
select is(
	o.mash_template('"{{^a.b.c}}Not Here{{/a.b.c}}" == ""', '{"a":{"b":{"c":true}}}'::jsonb),
	'"" == ""',
	'Dotted names should be valid for Inverted Section tags.');

-- Dotted Names - Falsey
select is(
	o.mash_template('"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"', '{"a":{"b":{"c":false}}}'::jsonb),
	'"Not Here" == "Not Here"',
	'Dotted names should be valid for Inverted Section tags.');

-- Dotted Names - Broken Chains
select is(
	o.mash_template('"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"', '{"a":{}}'::jsonb),
	'"Not Here" == "Not Here"',
	'Dotted names that cannot be resolved should be considered falsey.');

-- Nested (Falsey)
select is(
	o.mash_template('| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |', '{"bool":false}'::jsonb),
	'| A B C D E |',
	'Nested falsey sections should have their contents rendered.');

-- Nested (Truthy)
select is(
	o.mash_template('| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |', '{"bool":true}'::jsonb),
	'| A  E |',
	'Nested truthy sections should be omitted.');

-- Context Misses
select is(
	o.mash_template('[{{^missing}}Cannot find key «missing»!{{/missing}}]', '{}'::jsonb),
	'[Cannot find key «missing»!]',
	'Failed context lookups should be considered falsey.');

-- Doubled
select is(
	o.mash_template(e'{{^bool}}first{{/bool}}, {{two}}, {{^bool}}third{{/bool}}', '{"bool":false, "two":"second"}'::jsonb),
	'first, second, third',
	'Multiple inverted sections per template should be permitted.');

-- Context
select is(
	o.mash_template('"{{^context}}Hi {{name}}.{{/context}}"', '{"context": {"name": "Joe"}}'::jsonb),
	'""',
	'Objects and hashes should behave like truthy values.');

-- List
select is(
	o.mash_template('"{{^list}}{{n}}{{/list}}"', '{"data": {"list": [{"n":1}, {"n":2}, {"n":3}]}}'::jsonb),
	'""',
	'Lists should behave like truthy values.');

-- Empty List
select is(
	o.mash_template('"{{^list}}Yay lists!{{/list}}"', '{"list":[]}'::jsonb),
	'"Yay lists!"',
	'Empty lists should behave like falsey values.');

-- Falsey
select is(
	o.mash_template('"{{^boolean}}This should be rendered.{{/boolean}}"', '{"boolean": false}'::jsonb),
	'"This should be rendered."',
	'Falsey sections should have their contents rendered.');

-- Truthy
select is(
	o.mash_template('"{{^boolean}}This should not be rendered.{{/boolean}}"', '{"boolean": true}'::jsonb),
	'""',
	'Truthy sections should have their contents omitted.');

-- Null is falsey
select is(
	o.mash_template('"{{^null}}This should be rendered.{{/null}}"', '{"null": null}'::jsonb),
	'"This should be rendered."',
	'Null is falsey');

-- No Interpolation
select is(
	o.mash_template('Hello from {Mustache}!', '{}'::jsonb),
	'Hello from {Mustache}!',
	'Mustache-free templates should render as-is.');

-- Basic Interpolation
select is(
	o.mash_template('Hello, {{subject}}!', '{"subject": "world"}'::jsonb),
	'Hello, world!',
	'Unadorned tags should interpolate content into the template.');

-- Basic Integer Interpolation
select is(
	o.mash_template('"{{mph}} miles an hour!"', '{"mph": 85}'::jsonb),
	'"85 miles an hour!"',
	'Integers should interpolate seamlessly.');

-- HTML Escaping
select is(
	o.mash_template('These characters should be HTML escaped: {{forbidden}}', '{"forbidden": "& \" < >"}'::jsonb),
	'These characters should be HTML escaped: &amp; &quot; &lt; &gt;',
	'Basic interpolation should be HTML escaped.');

-- Triple Mustache
select is(
	o.mash_template('These characters should not be HTML escaped: {{{forbidden}}}', '{"forbidden": "& \" < >"}'::jsonb),
	'These characters should not be HTML escaped: & " < >',
	'Triple mustaches should interpolate without HTML escaping.');

-- Triple Mustache Integer Interpolation
select is(
	o.mash_template('"{{{mph}}} miles an hour!"', '{"mph": 85}'::jsonb),
	'"85 miles an hour!"',
	'Integers should interpolate seamlessly.');

-- Basic Null Interpolation
select is(
	o.mash_template('"I ({{cannot}}) be seen!"', '{"cannot": null}'::jsonb),
	'"I () be seen!"',
	'Nulls should interpolate as the empty string.');

-- Triple Mustache Null Interpolation
select is(
	o.mash_template('"I ({{{cannot}}}) be seen!"', '{"cannot": null}'::jsonb),
	'"I () be seen!"',
	'Nulls should interpolate as the empty string.');

-- Basic Context Miss Interpolation
select is(
	o.mash_template('"I ({{cannot}}) be seen!"', '{}'::jsonb),
	'"I () be seen!"',
	'Failed context lookups should default to empty strings.');

-- Triple Mustache Context Miss Interpolation
select is(
	o.mash_template('"I ({{{cannot}}}) be seen!"', '{}'::jsonb),
	'"I () be seen!"',
	'Failed context lookups should default to empty strings.');

-- Deeply Nested Contexts
select is(
	o.mash_template('{{#a}}{{one}}
{{#b}}
{{one}}{{two}}{{one}}
{{#c}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{#d}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{#five}}
{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
{{one}}{{two}}{{three}}{{four}}{{.}}6{{.}}{{four}}{{three}}{{two}}{{one}}
{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
{{/five}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{/d}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{/c}}
{{one}}{{two}}{{one}}
{{/b}}
{{one}}{{/a}}',
	'{"a":{"one":1},"b":{"two":2},"c":{"three":3,"d":{"four":4,"five":5}}}'::jsonb),
	'1
121
12321
1234321
123454321
12345654321
123454321
1234321
12321
121
1',
	'All elements on the context stack should be accessible');

-- List
select is(
	o.mash_template('"{{#list}}{{item}}{{/list}}"', '{"list":[{"item":1},{"item":2},{"item":3}]}'::jsonb),
	'"123"',
	'Lists should be iterated; list items should visit the context stack.');

-- Empty List
select is(
	o.mash_template('"{{#list}}Yay lists!{{/list}}"', '{"list":[]}'::jsonb),
	'""',
	'Empty lists should behave like falsey values.');

-- Doubled
select is(
	o.mash_template('{{#bool}}first{{/bool}}, {{two}}, {{#bool}}third{{/bool}}', '{"bool":true,"two":"second"}'::jsonb),
	'first, second, third',
	'Multiple sections per template should be permitted.');

-- Nested (Truthy)
select is(
	o.mash_template('| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |', '{"bool":true}'::jsonb),
	'| A B C D E |',
	'Nested truthy sections should have their contents rendered.');

-- Nested (Falsey)
select is(
	o.mash_template('| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |', '{"bool":false}'::jsonb),
	'| A  E |',
	'Nested falsey sections should be omitted.');

-- Context Misses
select is(
	o.mash_template('[{{#missing}}Found key «missing»!{{/missing}}]', '{}'::jsonb),
	'[]',
	'Failed context lookups should be considered falsey.');

-- Implicit Iterator - String
select is(
	o.mash_template('"{{#list}}({{.}}){{/list}}"', '{"list":["a","b","c","d","e"]}'::jsonb),
	'"(a)(b)(c)(d)(e)"',
	'Implicit iterators should directly interpolate strings.');

-- Implicit Iterator - Integer
select is(
	o.mash_template('"{{#list}}({{.}}){{/list}}"', '{"list":[1,2,3,4,5]}'::jsonb),
	'"(1)(2)(3)(4)(5)"',
	'Implicit iterators should cast integers to strings and interpolate.');

-- Implicit Iterator - Array
select is(
	o.mash_template('"{{#list}}({{#.}}{{.}}{{/.}}){{/list}}"', '{"list":[[1,2,3],["a","b","c"]]}'::jsonb),
	'"(123)(abc)"',
	'Implicit iterators should allow iterating over nested arrays.');

-- Implicit Iterator - HTML Escaping
select is(
	o.mash_template('"{{#list}}({{.}}){{/list}}"', '{"list": [ "&", "<", ">" ]}'::jsonb),
	'"(&amp;)(&lt;)(&gt;)"',
	'Implicit iterators with basic interpolation should be HTML escaped.');

-- Implicit Iterator - Triple mustache
select is(
	o.mash_template('"{{#list}}({{{.}}}){{/list}}"', '{"list": [ "&", "<", ">" ]}'::jsonb),
	'"(&)(<)(>)"',
	'Implicit iterators in triple mustache should interpolate without HTML escaping.');

-- Dotted Names - Truthy
select is(
	o.mash_template('"{{#a.b.c}}Here{{/a.b.c}}" == "Here"', '{"a":{"b":{"c":true}}}'::jsonb),
	'"Here" == "Here"',
	'Dotted names should be valid for Section tags.');

-- Dotted Names - Broken Chains
select is(
	o.mash_template('"{{#a.b.c}}Here{{/a.b.c}}" == ""', '{"a":{}}'::jsonb),
	'"" == ""',
	'Dotted names that cannot be resolved should be considered falsey.');

