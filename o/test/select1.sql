select plan(3);

select is('[{"code": "a", "show": "a", "selected": ""}, {"code": "b", "show": "b", "selected": " selected"}, {"code": "c", "show": "c", "selected": ""}]'::jsonb,
o.select1('["a","b","c"]'::jsonb, 'b'), 'scalar');


select is('[{"code": "a", "show": "Apple", "selected": ""}, {"code": "b", "show": "Boy", "selected": " selected"}]'::jsonb,
o.select1('[{"code":"a", "show":"Apple"},{"code":"b", "show":"Boy"}]'::jsonb, 'b'), 'object key show');


select is('[{"code": "a", "show": "Apple", "selected": " selected"}, {"code": "b", "show": "Boy", "selected": ""}]'::jsonb, 
o.select1('[{"code":"a", "name":"Apple"},{"code":"b", "name":"Boy"}]'::jsonb, 'a'), 'object key name');

