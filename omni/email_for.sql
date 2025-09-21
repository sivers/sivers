create function o.email_for(_pid integer, out email text) as $$
	select email
	from ats
	where person_id = $1
	order by used desc nulls last
	limit 1;
$$ language sql stable;

-- same but without listype = 'none'
create function o.email_nonone_for(_pid integer, out email text) as $$
	select email
	from ats
	where person_id = $1
	and (listype != 'none' or listype is null)
	order by used desc nulls last
	limit 1;
$$ language sql stable;

