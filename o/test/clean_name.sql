select plan(3);

select is(o.clean_name('  A      B '), 'A B');
select is(o.clean_name(e'\r\n\t  A \t\r\n B '), 'A B');
select is(o.clean_name(' A <script><alert>"gotcha"</alert></script> B '), 'A "gotcha" B');

