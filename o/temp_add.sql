-- using person_id
create function o.temp_add(_personid integer)
returns table(person_id integer, name text, email text, temp char(16)) as $$
	with pq as (
		select people.id, people.name, o.email_for(people.id) as email
		from people
		where id = $1
	), tq as (
		insert into temps (person_id) values ($1)
		-- if person already in temps, temp code is extended, not changed
		on conflict on constraint temps_person_id_key do
			update set expires = now() + interval '1 month'
		returning temp
	)
	select pq.id, pq.name, pq.email, tq.temp from pq, tq;
$$ language sql;

-- using name, email
create function o.temp_add(_name text, _email text)
returns table(person_id integer, name text, email text, temp char(16)) as $$
declare
	e text;
	pid integer;
begin
	if $1 is null or $2 is null then
		raise 'no_null';
	end if;
	e = o.clean_email($2);
	select x.pid into pid from o.pid_from_email(e) x;
	if pid is not null then
		-- make sure temp_add(pid) uses this email
		update ats set used = now() where ats.email = e;
		return query select * from o.temp_add(pid);
	else
		-- is email is already in temps.new_email?
		update temps
		set expires = now() + interval '1 month'
		where new_email = e;
		if found then
			return query select temps.person_id,
				temps.new_name,
				temps.new_email,
				temps.temp
			from temps
			where new_email = e;
		else
			-- new person doesn't get an entry in people, so person_id is null
			-- name & email only in temps until they click the tempcode link
			return query insert into temps (new_name, new_email)
			values (o.clean_name($1), e)
			returning temps.person_id,
				temps.new_name,
				temps.new_email,
				temps.temp;
		end if;
	end if;
end;
$$ language plpgsql;

