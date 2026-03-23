-- sive.rs/met/at-#
-- only show meetings with topics, since that's what I enter last

create function me.metat(_whereid integer, out body text) as $$
declare
	mw meetwheres;
begin
	select * into mw from meetwheres where id = $1;
	body = o.template('me-wrap', 'me-metat', jsonb_build_object(
		'pagetitle', mw.display || ' - Derek Sivers meetings',
		'place', mw.display,
		'location', mw.location,
		'thoughts', mw.thoughts,
		'meetings', (select jsonb_agg(r) from (
			select meetings.id, people.name, meetings.topics
			from meetings
			join people on meetings.person_id = people.id
			where where_id = $1
			and whatime < now()
			and topics is not null
			order by whatime
		) r)
	));
end;
$$ language plpgsql;

