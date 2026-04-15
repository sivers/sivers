-- sive.rs/met
-- only show places for meetings that have passed
create function me.met(out body text) as $$
	select o.template('me-wrap', 'me-met', jsonb_build_object(
		'pagetitle', 'Derek Sivers meetings',
		'howmany', (select count(*) from meetings where whatime < now() and topics is not null),
		'places', (select jsonb_agg(r) from (
			select id, display from meetwheres where id in (
				select where_id from meetings where whatime < now() and topics is not null
			)
			order by id desc
		) r)
	));
$$ language sql;

