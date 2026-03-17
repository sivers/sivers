create function mynow.publicid(kk char(32)) returns char(4) as $$
	select now_profiles.public_id
	from logins
	join now_profiles on logins.person_id = now_profiles.id
	where logins.cookie = $1;
$$ language sql;

