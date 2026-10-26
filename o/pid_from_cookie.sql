-- using the "out" argument format so that return integer is named pid
create function o.pid_from_cookie(_cookie text, out pid integer) as $$
	select person_id
	from logins
	where length($1) = 32
	and logins.cookie = $1::char(32);
$$ language sql stable;
