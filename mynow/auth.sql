-- my.nownownow.com auth only for people with now_pages
-- returns logins.person_id as pid if OK
create function mynow.auth(_cookie text, out pid integer) as $$
	select logins.person_id
	from logins
	where length($1) = 32
	and logins.cookie = $1::char(32)
	and exists (
		select 1 from now_pages
		where now_pages.person_id = logins.person_id
	);
$$ language sql stable;
