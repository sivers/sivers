insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-presentation', 'uri:{{uri}}
title:{{title}}
description:{{{description}}}
month:{{month}}
minutes:{{minutes}}
transcript:{{{transcript}}}
{{#mp3s}}
filename:{{filename}}
{{/mp3s}}
{{#mp4s}}
filename:{{filename}}
{{/mp4s}}
');

insert into presentations (uri, title, description, month, minutes, transcript) values ('xx', 'X Talk', '<p><strong>Description about X!</strong>.</p>', '2026-03', 123, '<p>Hello.</p><p>Me &amp; my mouth are talking.</p>');

insert into audios (id, filename) values (1, '2026-03-xx-1.mp3');
insert into audios (id, filename) values (2, '2026-03-xx-2.mp3');
insert into videos (id, filename) values (1, '2026-03-xx-1.mp4');
insert into videos (id, filename) values (2, '2026-03-xx-2.mp4');
insert into media (presentation, audio, sortid) values ('xx', 2, 2);
insert into media (presentation, audio, sortid) values ('xx', 1, 1);
insert into media (presentation, video, sortid) values ('xx', 1, 1);
insert into media (presentation, video, sortid) values ('xx', 2, 2);

select plan(1);
select is(body, '<title>X Talk by Derek Sivers</title><body>uri:xx
title:X Talk
description:<p><strong>Description about X!</strong>.</p>
month:2026-03
minutes:123
transcript:<p>Hello.</p><p>Me &amp; my mouth are talking.</p>
filename:2026-03-xx-1.mp3
filename:2026-03-xx-2.mp3
filename:2026-03-xx-1.mp4
filename:2026-03-xx-2.mp4
</body>')
from me.presentation('xx');
