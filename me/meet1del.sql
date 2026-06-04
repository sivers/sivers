-- meeting-person needs to choose a different time,
-- so delete their existing choice then redirect to choose anew
create function me.meet1del(_tempcode text,
	out head text, out body text) as $$
declare
	mid integer;
begin
	select meetings.id into mid
	from temps
	join meetings on temps.person_id = meetings.person_id
	where temps.temp = $1
	and (meetings.whatime is null or meetings.whatime > now());

	if mid is null then
		head = e'303\r\nLocation: /sorry?for=badurlid';
	else
		update meetavails
		set person_id = null, meeting_id = null
		where meeting_id = mid;

		update meetings
		set whatime = null
		where id = mid;

		head = e'303\r\nLocation: /meet1?t=' || $1;
	end if;

end;
$$ language plpgsql;

