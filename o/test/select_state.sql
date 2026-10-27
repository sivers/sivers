insert into countries (code, name) values ('GB','United Kingdom');
insert into countries (code, name) values ('US','United States');
insert into states (country, code, name) values ('GB', 'WLS', 'Wales');
insert into states (country, code, name) values ('GB', 'ENG', 'England');
insert into states (country, code, name) values ('US', 'OR', 'Oregon');
insert into states (country, code, name) values ('US', 'AK', 'Alaska');

select plan(7);

select is(o.select_state(null, null),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

select is(o.select_state('GB', null),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

select is(o.select_state('GB', 'XXX'),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

select is(o.select_state('GB', ''),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

select is(o.select_state('GB', 'WLS'),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": " selected"}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

select is(o.select_state('US', 'OR'),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": " selected"}]
}'::jsonb);

select is(o.select_state(),
'{"GB": [
 {"code": "ENG", "show": "England", "selected": ""},
 {"code": "WLS", "show": "Wales", "selected": ""}],
 "US": [
 {"code": "AK", "show": "Alaska", "selected": ""},
 {"code": "OR", "show": "Oregon", "selected": ""}]
}'::jsonb);

