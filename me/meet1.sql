-- someone I want to meet with can claim or change the time of our meeting
create function me.meet1(_tempcode text,
	out head text, out body text) as $$
declare
	nam text;
	pid integer;
	mid integer;
	wid integer;
	wtm timestamptz(0); 
	loc text;
	tzn varchar(32);
begin
	-- temp code linked to person with future meeting?
	select people.name, meetings.person_id, meetings.id, meetings.where_id, meetings.whatime
	into nam, pid, mid, wid, wtm
	from temps
	join meetings on temps.person_id = meetings.person_id
	join people on meetings.person_id = people.id
	where temps.temp = $1
	and (meetings.whatime is null or meetings.whatime > now());
	if pid is null then
		head = e'303\r\nLocation: /sorry?for=badurlid';
		return;
	end if;

	-- load place info
	select location, tzname
	into loc, tzn
	from meetings
	join meetwheres on meetings.where_id = meetwheres.id
	where meetings.id = mid;

	-- they picked a time already?
	if wtm is not null then
		-- yes? show info with delete/change button
		body = o.template('me-wrap', 'me-meet1-change', jsonb_build_object(
			'pagetitle', 'your chosen time',
			'temp', $1, 'name', nam, 'location', loc,
			'when', trim(to_char(wtm at time zone tzn, 'HH24:MI AM Day DD Month'))
		));
	else
		-- no? show available times
		body = o.template('me-wrap', 'me-meet1-avails', jsonb_build_object(
			'pagetitle', 'choose a time',
			'temp', $1, 'name', nam, 'location', loc,
			'avails', (select jsonb_agg(r) from (
				select meetavails.id,
				trim(to_char(startime at time zone meetwheres.tzname, 'HH24:MI AM Day DD Month')) as start,
				trim(to_char(stoptime at time zone meetwheres.tzname, 'HH24:MI AM')) as stop
				from meetavails
				join meetwheres on meetavails.where_id = meetwheres.id
				where where_id = wid
				and meeting_id is null
				and startime > now()
				order by startime
			) r)
		));
	end if;
end;
$$ language plpgsql;

