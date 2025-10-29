create function peep.home(
	out head text, out body text) as $$
declare
	unopened jsonb;
	open jsonb;
begin
	unopened = coalesce((select jsonb_agg(r) from (
		select category, count(*)
		from emails
		where opened_by is null
		group by category
		order by count desc, category asc
	) r), '[]');
	open = coalesce((select jsonb_agg(r) from (
		select emails.id,
		emails.subject,
		people.name as by,
		substring(age(now(), emails.opened_at)::text, 0, 9) as age
		from emails
		join people on emails.opened_by = people.id
		where emails.opened_by is not null
		and emails.closed_by is null
		order by emails.id
	) r), '[]');
	body = o.template('peep-wrap', 'peep-home', jsonb_build_object(
		'unopened', unopened,
		'open', open
	));
end;
$$ language plpgsql;

