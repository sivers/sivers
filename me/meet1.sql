-- someone I want to meet with : forms to claim or change the time of our meeting
-- form to show my availabilities and optionally the time they chose already
create function me.meet1(_tempcode text,
	out head text, out body text) as $$
declare
	nam text;
	pid integer;
	mid integer;
	cid integer;
	wtm timestamptz(0); 
	loc text;
	tzn varchar(32);
begin
	-- temp code linked to person with future meeting?
	select people.name, meetings.person_id, meetings.id, meetings.meetcat, meetings.whatime
	into nam, pid, mid, cid, wtm
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
		-- [{"day":"Friday October 2", "times":[{id, start, stop}]}]
		body = o.template('me-wrap', 'me-meet1-avails', jsonb_build_object(
			'pagetitle', 'choose a time',
			'temp', $1, 'name', nam, 'location', loc,
			'avails', (select jsonb_agg(r) from (select
				to_char((startime at time zone tzname)::date, 'FMDay FMMonth FMDD') as day,
				json_agg(json_build_object(
					'id', id,
					'start', to_char(startime at time zone tzname, 'FMHH12AM'),
					'stop',  to_char(stoptime  at time zone tzname, 'FMHH12AM')
				) order by startime) as times
				from meetavails
				where meetcat = cid
				and meeting_id is null
				and startime > now()
				group by (startime at time zone tzname)::date
				order by (startime at time zone tzname)::date
			) r)
		));
	end if;
end;
$$ language plpgsql;

