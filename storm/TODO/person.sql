	js = row_to_json(r) from (
		select people.id, people.name,
		string_agg(ats.email, ',') as emails,
		coalesce((select json_agg(z) from (
			select * from view_invoice
			where person_id = $1
			order by id
		) z), '[]') as invoices
		from people
		left join ats on people.id = ats.person_id
		where people.id = $1
		group by people.id, people.name
	) r;
