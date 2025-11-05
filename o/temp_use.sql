-- temp_get (other file) is for when the person comes to /e?t=abcdefghijklmnop - just to see if the code is found, and welcome them
-- temp_use (this file) is for when the person clicks the login button. That's when we delete the temp code.

-- IN: temp code, person_id
-- DELETES temp and returns person_id and login cookie
create function o.temp_use(_tempcode char(16), _pid integer,
	out person_id integer, out cookie char(32)) as $$
begin
	delete from temps
	where temps.temp = $1
	and temps.person_id = $2
	returning temps.person_id into temp_use.person_id;
	if temp_use.person_id is not null then
		select login.cookie into temp_use.cookie
		from o.login($2);
	end if;
end;
$$ language plpgsql;
