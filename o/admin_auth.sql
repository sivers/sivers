-- for admins only, given email & password, and name of app,
-- return person.id if password correct and they're in admin_auths for this app
-- (use o.admin_pass_set to set the encrypted password)
create function o.admin_auth(_email text, _pass text, _app text) returns integer as $$
	select max(admin_auths.person_id) -- max() so null if not found
	from admin_auths
	join admins on admin_auths.person_id = admins.person_id
	join ats on admin_auths.person_id = ats.person_id
	where ats.email = $1
	and admins.hashpass = crypt($2, admins.hashpass)
	and admin_auths.appcode = $3;
$$ language sql;
