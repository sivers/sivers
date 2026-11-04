insert into templates (code, template) values ('me-wrap', '<html><title>{{pagetitle}}</title>
{{{core}}}
</html>');
insert into templates (code, template) values ('st0re-home', 'country={{country}}
currency={{currency}}
cart={{cart}}');

select plan(2);

select is(head, null),
	is(body, '<html><title>buy Derek Sivers books</title>
country=NZ
currency=NZD
cart=11-1
</html>')
from st0re.home('NZ', 'NZD', '11-1');

