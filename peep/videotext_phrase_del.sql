-- delete a phrase so I can re-do it
-- (phrase is always just a grouped clone of the words)
create function peep.videotext_phrase_del(_id integer,
	out head text, out body text) as $$
declare
	vidid integer;
begin
	delete from videotext
	where id = $1
	and kind  = 'phrase'
	returning video_id into vidid;

	head = e'303\r\nLocation: /vt/' || vidid;
end;
$$ language plpgsql;

