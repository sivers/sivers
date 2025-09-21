-- using the "out" argument format so that return integer is named pid
create function o.pid_from_cookie(_cookie text, out pid integer) as $$
	select person_id
	from logins
	where cookie = $1;
$$ language sql stable;
