insert into templates (code, template) values ('me-wrap', '<title>{{pagetitle}}</title><body>{{{core}}}</body>');
insert into templates (code, template) values ('me-interview', 'id:{{id}}
uri:{{uri}}
ymd:{{ymd}}
title:{{title}}
their_url:{{their_url}}
summary:{{summary}}
mp3:{{mp3}}
mp4:{{mp4}}
{{#segments}}
speaker:{{speaker}}
content:{{content}}
{{/segments}}
');

insert into interviews (id, uri, ymdhm, name, host, their_url, summary) values (1, '2026-01-one', '2026-01-02 12:00:00', 'One Show', 'One Host', 'https://one.host/', 'One summary here.');

insert into audios (id, filename) values (1, '2026-01-one.mp3');
insert into videos (id, filename) values (1, '2026-01-one.mp4');
insert into media (interview, audio) values (1, 1);
insert into media (interview, video) values (1, 1);

insert into utterances (interview_id, seconds, utype, speaker, content) values (1, 10, 'question', 'One Host', 'Welcome to the show.');
insert into utterances (interview_id, seconds, utype, speaker, content) values (1, 20, 'answer', 'sivers', 'Thank you.');

select plan(1);
select is(body, '<title>One Show by One Host | Derek Sivers</title><body>id:1
uri:2026-01-one
ymd:2026-01-02
title:One Show by One Host
their_url:https://one.host/
summary:One summary here.
mp3:2026-01-one.mp3
mp4:2026-01-one.mp4
speaker:One Host
content:Welcome to the show.
speaker:Derek Sivers
content:Thank you.
</body>')
from me.interview('2026-01-one');
