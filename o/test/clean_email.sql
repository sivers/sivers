select plan(3);

select is(o.clean_email('  A@B.CoM '), 'a@b.com');
select is(o.clean_email(e'\r\n\t  A@B.CoM \t\r\n'), 'a@b.com');
select is(o.clean_email('<THIS@th.at>'), 'this@th.at');

