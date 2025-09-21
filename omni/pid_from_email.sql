create function o.pid_from_email(_email_address text, out pid integer) as $$
	select person_id
	from ats
	where email = o.clean_email($1);
$$ language sql stable;
