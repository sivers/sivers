insert into templates (code, template) values ('me-wrap', '<html><title>{{pagetitle}}</title>
{{{core}}}
</html>');
insert into templates (code, template) values ('store-home', 'country={{country}}
currency={{currency}}
cart={{cart}}');

select plan(2);

select is(head, null),
	is(body, '<html><title>buy Derek Sivers books</title>
country=NZ
currency=NZD
cart=11-1
</html>')
from store.home('NZ', 'NZD', '11-1');

