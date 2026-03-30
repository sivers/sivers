insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-presentations', '<h1>{{howmany}} presentations</h1>
{{#presentations}}
uri:{{uri}}
title:{{title}}
description:{{description}}
month:{{month}}
minutes:{{minutes}}
{{/presentations}}
');

insert into presentations (uri, title, description, month, minutes) values ('blah', 'Blah Blah', 'Blah blah blah, and blah.', '2023-03', 33);
insert into presentations (uri, title, description, month, minutes) values ('six', 'Sixty', 'Six oh six.', '2026-06', 6);


select plan(1);
select is(body, '<title>Derek Sivers TED talks, conference presentations</title><body><h1>2 presentations</h1>
uri:six
title:Sixty
description:Six oh six.
month:2026-06
minutes:6
uri:blah
title:Blah Blah
description:Blah blah blah, and blah.
month:2023-03
minutes:33
</body>')
from me.presentations();
