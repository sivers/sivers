-- temp_get is for when the person comes to /e?t=abcdefghijklmnop - just to see if the code is found, and welcome them
-- temp_use (not here) is for when the person clicks the login button. That's when we delete the temp code.

-- IN: person_id
-- returns person_id, name, email, temp
-- PRIVATE: DO NOT USE. ONLY FOR FUNCTIONS BELOW.
create function o.temp_get_id(_pid integer)
returns table(person_id integer, name text, email text, temp char(16)) as $$
	select people.id,
		people.name,
		o.email_for(people.id) as email,
		temps.temp
	from temps
	join people on temps.person_id = people.id
	where temps.person_id = $1
	and temps.expires > now()
$$ language sql stable;

-- IN: temp code
-- returns person_id, name, email, temp
-- ONLY USE THIS WHEN A REAL PERSON HAS CLICKED THE LINK, since it adds person
create function o.temp_get(_tempcode char(16))
returns table(person_id integer, name text, email text, temp char(16)) as $$
declare
	r record;
	pid integer;
begin
	-- first, is this code found at all?
	select * into r
	from temps
	where temps.temp = $1
	and temps.expires > now();
	-- if yes + has a person_id, then get stored person
	if r.person_id is not null then
		return query select * from o.temp_get_id(r.person_id);
	-- if yes + has email, then insert new person
	elsif r.new_email is not null and r.new_name is not null then
		select z.pid into pid
		from o.person_create(r.new_name, r.new_email) z;
		-- update temps with that person_id, for temp_use
		update temps
		set person_id = pid, new_email = null, new_name = null
		where temps.temp = $1;
		return query select * from o.temp_get_id(pid);
	else
	-- not found, no rows returned
	end if;
end;
$$ language plpgsql;

-- IN: temp code
-- returns person_id, name, email, temp
-- THE DIFFERENCE: this doesn't add the person into people table
-- USE FOR EMAILING TEMP LINK, when it still might be a bot
create function o.temp_get_only(_tempcode char(16))
returns table(person_id integer, name text, email text, temp char(16)) as $$
declare
	r record;
	pid integer;
begin
	-- first, is this code found at all?
	select * into r
	from temps
	where temps.temp = $1
	and temps.expires > now();
	-- if has a person_id, then get stored person
	if r.person_id is not null then
		return query select * from o.temp_get_id(r.person_id);
	-- no person_id, return just null, name, email, temp
	elsif r.new_email is not null and r.new_name is not null then
		return query select r.person_id, r.new_name, r.new_email, r.temp;
	else
	-- not found, no rows returned
	end if;
end;
$$ language plpgsql;

