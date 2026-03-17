insert into sentences (code, sentence) values ('aaaaaaaa', 'One two three, four five six.');
insert into sentences (code, sentence) values ('bbbbbbbb', 'Seven eight nine.');

insert into videos (id, name) values (1, 'test');

insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (1, 1, 'word', 'aaaaaaaa', 1, 2, 'One');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (2, 1, 'word', 'aaaaaaaa', 2, 3, 'two');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (3, 1, 'word', 'aaaaaaaa', 3, 3.5, 'three,');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (4, 1, 'word', 'aaaaaaaa', 4, 5, 'four');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (5, 1, 'word', 'aaaaaaaa', 5, 6, 'five');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (6, 1, 'word', 'aaaaaaaa', 6, 6.5, 'six.');

insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (10, 1, 'phrase', 'aaaaaaaa', 1, 3.5, 'One two three,');

select plan(6);

select is(body, null),
	is(head, e'303\r\nLocation: /vt/1')
from peep.videotext_phrase_upd(10, ' s0 ', null);

select is(body, null),
	is(head, e'303\r\nLocation: /vt/1')
from peep.videotext_phrase_upd(10, '', 'One TWO three!');

select is(style, 's0', 'trims spaces'),
	is(word, 'One TWO three!')
from videotext where id = 10;

