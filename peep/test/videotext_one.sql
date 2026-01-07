insert into sentences (code, sentence) values ('aaaaaaaa', 'One two three, four five six.');
insert into sentences (code, sentence) values ('bbbbbbbb', 'Seven eight nine.');

insert into videos (id, name) values (1, 'test');

insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (1, 1, 'word', 'aaaaaaaa', 1, 2, 'one');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (2, 1, 'word', 'aaaaaaaa', 2, 3, 'two');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (3, 1, 'word', 'aaaaaaaa', 3, 3.5, 'three');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (4, 1, 'word', 'aaaaaaaa', 4, 5, 'four');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (5, 1, 'word', 'aaaaaaaa', 5, 6, 'five');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (6, 1, 'word', 'aaaaaaaa', 6, 6.5, 'six');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (7, 1, 'word', 'bbbbbbbb', 7, 8, 'seven');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (8, 1, 'word', 'bbbbbbbb', 8, 9, 'eight');
insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (9, 1, 'word', 'bbbbbbbb', 9, 9.8, 'nine');

insert into videotext (id, video_id, kind, sentence_code, startime, stoptime, word) values (10, 1, 'phrase', 'aaaaaaaa', 1, 3.5, 'One two three,');

insert into templates values ('peep-wrap', '<html>{{{core}}}</html>');
insert into templates values ('peep-videotext1', '<table>
{{#phrases}}
<tr>
	<td><form action="/vt/phrase/del/{{id}}" method="post"><input type="submit" value="del"></form></td>
	<td>{{video_id}}</td>
	<td>{{startime}}</td>
	<td>{{stoptime}}</td>
	<td>{{word}}</td>
</tr>
{{/phrases}}
</table>

<table>
{{#words}}
<tr>
	<td>{{sentence_code}}</td>
	<td>{{startime}}</td>
	<td>{{stoptime}}</td>
{{#totaltext}}
	<td>{{totaltext}}</td>
	<td><form action="/vt/phrase/add/{{start_id}}/{{id}}" method="post"><input type="submit" value="add"></form></td>
{{/totaltext}}
{{^totaltext}}
	<td>{{word}}</td><td></td>
{{/totaltext}}
</tr>
{{/words}}
</table>');

select plan(2);

select is(head, null),
	is(body, '<html><table>
<tr>
	<td><form action="/vt/phrase/del/10" method="post"><input type="submit" value="del"></form></td>
	<td>1</td>
	<td>1</td>
	<td>3.5</td>
	<td>One two three,</td>
</tr>
</table>

<table>
<tr>
	<td>aaaaaaaa</td>
	<td>4</td>
	<td>5</td>
	<td>four</td>
	<td><form action="/vt/phrase/add/4/4" method="post"><input type="submit" value="add"></form></td>
</tr>
<tr>
	<td>aaaaaaaa</td>
	<td>5</td>
	<td>6</td>
	<td>four five</td>
	<td><form action="/vt/phrase/add/4/5" method="post"><input type="submit" value="add"></form></td>
</tr>
<tr>
	<td>aaaaaaaa</td>
	<td>6</td>
	<td>6.5</td>
	<td>four five six</td>
	<td><form action="/vt/phrase/add/4/6" method="post"><input type="submit" value="add"></form></td>
</tr>
<tr>
	<td>bbbbbbbb</td>
	<td>7</td>
	<td>8</td>
	<td>seven</td><td></td>
</tr>
<tr>
	<td>bbbbbbbb</td>
	<td>8</td>
	<td>9</td>
	<td>eight</td><td></td>
</tr>
<tr>
	<td>bbbbbbbb</td>
	<td>9</td>
	<td>9.8</td>
	<td>nine</td><td></td>
</tr>
</table></html>')
from peep.videotext_one(1);

