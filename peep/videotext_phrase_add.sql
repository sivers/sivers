-- using timings and words from videotext word #1 until word #2
-- insert a new phrase for use as a subtitle
create function peep.videotext_phrase_add(_id1 integer, _id2 integer,
	out head text, out body text) as $$
declare
	-- the stuff to insert:
	vidid integer;
	sencode char(8);
	time1 real;
	time2 real;
	phrase text;
begin
	select video_id, sentence_code, startime
	into vidid, sencode, time1
	from videotext
	where id = $1;

	select stoptime into time2
	from videotext
	where id = $2;

	select string_agg(word, ' ' order by id) into phrase
	from videotext
	where kind = 'word'
	and id >= $1
	and id <= $2;

	insert into videotext (video_id, kind, sentence_code, startime, stoptime, word)
	values (vidid, 'phrase', sencode, time1, time2, phrase);

	head = e'303\r\nLocation: /vt/' || vidid;
end;
$$ language plpgsql;

