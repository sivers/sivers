-- returns true/false if this cookie belongs to stork admin
create function stork.auth(_cookie char(32)) returns boolean as $$
	select exists (
		select 1
		from logins
		where length($1) = 32
		and logins.cookie = $1
		and exists (
			select 1 from admin_auths
			where admin_auths.person_id = logins.person_id
			and admin_auths.appcode = 'stork'
		)
	);
$$ language sql stable;
