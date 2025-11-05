-- create random 32 char in logins table, for use in giving client cookie
create function o.login(_pid integer, out cookie char(32)) as $$
begin
	-- first, if already exists for this person, return that
	select logins.cookie into login.cookie
	from logins
	where person_id = $1;
	-- if not found, insert & create (table generates random string)
	if login.cookie is null then
		insert into logins (person_id)
		values ($1)
		returning logins.cookie into login.cookie;
	end if;
end;
$$ language plpgsql;
