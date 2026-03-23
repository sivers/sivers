create function me.interviews(out body text) as $$
begin
	body = o.template('me-wrap', 'me-interviews', jsonb_build_object(
		'pagetitle', 'interviews with Derek Sivers',
		'interviews', (select jsonb_agg(r) from (
			select uri, ymdhm::date as ymd,
			case when name = host then name else name || ' - by '|| host end as title,
			summary
			from interviews
			where uri in (select me.interview_uris())
			order by ymdhm desc
		) r)
	));
end;
$$ language plpgsql;

