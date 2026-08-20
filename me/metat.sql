-- sive.rs/met/at-#
-- only show meetings with topics, since that's what I enter last

create function me.metat(_cat integer, out body text) as $$
declare
	mc meetcats;
begin
	select * into mc from meetcats where id = $1;
	body = o.template('me-wrap', 'me-metat', jsonb_build_object(
		'pagetitle', mc.display || ' - Derek Sivers meetings',
		'place', mc.display,
		'thoughts', replace(o.escape_html(mc.thoughts), e'\n', e'\n<br>\n'),
		'meetings', (select jsonb_agg(r) from (
			select meetings.id, people.name, meetings.topics, meetings.location
			from meetings
			join people on meetings.person_id = people.id
			where meetcat = $1
			and whatime < now()
			and topics is not null
			order by whatime
		) r)
	));
end;
$$ language plpgsql;

