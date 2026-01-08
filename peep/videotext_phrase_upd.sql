-- update just the style or word of a videotext phrase - NULL if no change
-- oh but Go form doesn't do NULL, it does empty strings so look for both
-- means that I can't use this to set style or word to '', which is fine
create function peep.videotext_phrase_upd(_id integer, _style text, _word text,
	out head text, out body text) as $$
declare
	vidid integer;
begin
	select video_id into vidid from videotext where id = $1;

	if $2 is not null and $2 != '' then
		update videotext set style = btrim($2) where id = $1;
	end if;

	if $3 is not null and $3 != '' then
		update videotext set word = btrim($3) where id = $1;
	end if;

	head = e'303\r\nLocation: /vt/' || vidid;
end;
$$ language plpgsql;

