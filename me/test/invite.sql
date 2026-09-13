insert into people (id, name, greeting) values (1, 'Mrs. One', 'Onesey');
insert into people (id, name, greeting) values (2, 'Mr. Two', 'Twobody');
insert into invites (code, project, person_id) values ('abcdefgh', 'smtp', 1);
insert into invites (code, project, person_id) values ('ijklmnop', 'smtp', 2);

select plan(11);

select is(head, '404', 'too long'), is(body, null)
from me.invite('abcdefghI', 'smtp');

select is(head, '404', 'too short')
from me.invite('abcdefg', 'smtp');

select is(head, '404', 'code case sensitive')
from me.invite('abcdefgH', 'smtp');

select is(head, '404', 'project case sensitive')
from me.invite('abcdefgh', 'sMtp');

select is(head, '202', 'right, done, 202'), is(body, null)
from me.invite('abcdefgh', 'smtp');

select is(head, '404', '404 when already done'), is(body, null)
from me.invite('abcdefgh', 'smtp');

select is(head, '202', 'right2, done2, 202')
from me.invite('ijklmnop', 'smtp');

select is(head, '404', '404 already done2')
from me.invite('ijklmnop', 'smtp');

