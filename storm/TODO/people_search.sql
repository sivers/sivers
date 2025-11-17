	q := concat('%', btrim($1, e'\t\r\n '), '%');
	js = coalesce((select json_agg(r) from (
		select people.id, people.name,
		string_agg(ats.email, ',') as emails
		from people
		left join ats on people.id = ats.person_id
		where (people.name ilike q or company ilike q or ats.email ilike q)
		and people.id in (
			select person_id from invoices
		)
		group by people.id, people.name
		order by people.name, people.id
	) r), '[]');
