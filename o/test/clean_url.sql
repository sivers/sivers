select plan(3);

select is(o.clean_url(e'\r\n\t  sivers \t\r.\n com '), 'https://sivers.com');
select is(o.clean_url('book.com'), 'https://book.com');
select is(o.clean_url('http://scripting.com.'), 'http://scripting.com');

