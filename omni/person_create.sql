-- Use this to add a new person to the database.  Ensures unique email without clash.
-- always returns people.id, whether new insert or existing select
create function o.person_create(_name text, _email text, out pid integer) as $$
declare
	n text;
	e text;
begin
	n = o.clean_name($1);
	e = o.clean_email($2);
	if e is null or e !~ '\A\S+@\S+\.\S+\Z' then
		return;
	end if;
	select x.pid into pid from o.pid_from_email(e) x;
	-- not found? add name, cleaned
	if pid is null then
		insert into people (name, greeting)
		values (n, split_part(n, ' ', 1))
		returning people.id into pid;
		insert into ats (person_id, email)
		values (pid, e);
	else
		-- if email was found, update its used date
		update ats set used = now() where ats.email = e;
	end if;
end;
$$ language plpgsql;
