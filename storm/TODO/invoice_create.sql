		insert into invoices(person_id)
		values($1)
		returning id
