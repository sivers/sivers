select plan(2);

select is(o.clean_code(e'\r\n\t " A@B.CoM " \t\r\n'), 'abcom');
select is(o.clean_code('沈思问 €10 EUR'), 'eur');

