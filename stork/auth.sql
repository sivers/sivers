-- returns logins.person_id as pid if stork admin and OK
create function stork.auth(_cookie char(32), out pid integer) as $$
	select logins.person_id
	from logins
	where length($1) = 32
	and logins.cookie = $1
	and exists (
		select 1 from admin_auths
		where admin_auths.person_id = logins.person_id
		and admin_auths.appcode = 'stork'
	);
$$ language sql stable;
