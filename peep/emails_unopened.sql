create function peep.emails_unopened(_cat text,
	out head text, out body text) as $$
declare
	emails jsonb;
begin
	emails = coalesce((select json_agg(r) from (
		select id, created_at::date, subject, their_name
		from emails
		where opened_by is null
		and category = $1
		order by id
	) r), '[]');
	body = o.template('peep-wrap', 'peep-emails', jsonb_build_object(
		'emails', emails
	));
end;
$$ language plpgsql;

