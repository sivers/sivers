-- someone I want to meet claims a time, posting meetavails.id of their choice
create or replace function me.meet1set(_tempcode text, _availid integer,
	out head text, out body text) as $$
declare
	nam text;
	pid integer;
	mid integer;
	wid integer;
	wtm timestamptz(0); 
	atm timestamptz(0); 
	wid2 integer;
	mid2 integer;
	loc text;
	tzn varchar(32);
	showtime text;
	message text;
begin
	-- stop unless temp code linked to person with future meeting
	select people.name, meetings.person_id, meetings.id, meetings.where_id, meetings.whatime
	into nam, pid, mid, wid, wtm
	from temps
	join meetings on temps.person_id = meetings.person_id
	join people on meetings.person_id = people.id
	where temps.temp = $1
	and (meetings.whatime is null or meetings.whatime > now());
	if pid is null or mid is null then
		head = e'303\r\nLocation: /sorry?for=badurlid';
		return;
	end if;

	-- load their meetavails choice
	select startime, where_id, meeting_id
	into atm, wid2, mid2
	from meetavails
	where meetavails.id = $2;

	-- very unlikely but stop if posted meetavails.where_id doesn't match meetings.where_id
	if wid != wid2 then
		head = e'303\r\nLocation: /sorry';
		return;
	end if;

	-- they picked a time already?
	if wtm is not null then
		-- if same as this choice, just say thanks
		if wtm = atm then
			head = e'303\r\nLocation: /thanks?for=done';
		-- if different than new choice, redirect to chooser to do it right
		else
			head = e'303\r\nLocation: /meet1?t=' || $1;
		end if;
		return;
	else
		-- all good. do it.
		update meetavails set person_id = pid, meeting_id = mid where id = $2;
		update meetings set whatime = atm where id = mid;

		-- load place info for email message & subject
		select location, tzname
		into loc, tzn
		from meetings
		join meetwheres on meetings.where_id = meetwheres.id
		where meetings.id = mid;

		-- then send email
		showtime = trim(to_char(atm at time zone tzn, 'HH24:MI AM Day DD Month'));
		message = e'I look forward to meeting you. Thanks for picking a time.\n\nWHERE: ' || loc || e'\n\nWHEN: ' || showtime || e'\n\nIf you need to change or cancel, just go back to https://sive.rs/meet1?t=' || $1;
		perform o.email(0, pid, showtime || ' at ' || loc, message, null);
		head = e'303\r\nLocation: /thanks?for=done';
	end if;
end;
$$ language plpgsql;

