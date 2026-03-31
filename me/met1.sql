-- sive.rs/met/:id

create function me.met1(_id integer, out body text) as $$
declare
	p record;
	met1urls jsonb;
begin
	select meetings.id, people.name, meetings.where_id,
	meetwheres.location, meetwheres.display,
	meetings.whatime, meetings.notes
	from meetings into p
	join people on meetings.person_id = people.id
	join meetwheres on meetings.where_id = meetwheres.id
	where meetings.id = $1;

	select jsonb_agg(r) into met1urls from (
		select urls.url
		from meetings
		join urls on meetings.person_id = urls.person_id
		where meetings.id = $1
		order by urls.main desc nulls last, urls.id
	) r;

	body = o.template('me-wrap', 'me-met1', jsonb_build_object(
		'pagetitle', p.name || ' met with Derek Sivers',
		'id', p.id,
		'name', p.name,
		'where_id', p.where_id,
		'location', p.location,
		'display', p.display,
		'whatime', p.whatime,
		'notes', p.notes,
		'urls', met1urls
	));
end;
$$ language plpgsql;

