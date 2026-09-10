select plan(10);

select is(ts, '2026-03-02 13:00:00+00'::timestamptz) from o.ampm2ts('Europe/London',   '2026-03-02 1pm');
select is(ts, '2026-09-02 12:00:00+00'::timestamptz) from o.ampm2ts('Europe/London',   '2026-09-02 1pm');
select is(ts, '2026-09-02 10:00:00+00'::timestamptz) from o.ampm2ts('Europe/Istanbul', '2026-09-02 1pm');
select is(ts, '2026-09-02 07:30:00+00'::timestamptz) from o.ampm2ts('Asia/Kolkata',    '2026-09-02 1pm');

select is(ts, '2026-09-02 05:00:00+00'::timestamptz) from o.ampm2ts('Asia/Singapore',  '2026-09-02 1pm');
select is(ts, '2026-09-02 05:00:00+00'::timestamptz) from o.ampm2ts('Asia/Singapore',  '  2026-09-02 1 PM  ');

prepare p1 as select * from o.ampm2ts('Asia/Invalid-City', '2026-09-22 1pm');
select throws_ok('p1', 'wrong tz name: Asia/Invalid-City', 'valid timezone');

prepare p2 as select * from o.ampm2ts('', '2026-09-22 1pm');
select throws_ok('p2', 'wrong tz name: ', 'valid timezone');

prepare p3 as select * from o.ampm2ts('Asia/Singapore', '2026-09-22  1pm');
select throws_ok('p3', 'wrong ampm format: 2026-09-22  1pm', 'one space after date');

prepare p4 as select * from o.ampm2ts('Asia/Singapore', '2026-09-32 1pm');
select throws_ok('p4', 'date field value out of range: 2026-09-32', 'valid date');

