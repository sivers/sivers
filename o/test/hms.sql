select plan(5);

select is(hms, '0:00:00.00') from o.hms(0);
select is(hms, '0:00:59.99') from o.hms(59.9999);
select is(hms, '0:01:00.00') from o.hms(60);
select is(hms, '1:00:00.00') from o.hms(3600);
select is(hms, '3:25:45.67') from o.hms(12345.678);

