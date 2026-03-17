create function peep.email_open_next(kk char(32), _cat text,
	out head text, out body text) as $$
declare
	pid integer;
	eid integer;
begin
	select person_id into pid
	from logins
	where logins.cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;

	select id into eid
	from emails
	where opened_by is null
	and category = $2
	order by id asc limit 1;

	if eid is null then
		head = e'303\r\nLocation: /';
	else
		update emails
		set opened_by = pid, opened_at = now()
		where id = eid;
		head = e'303\r\nLocation: /email/' || eid;
	end if;
end;
$$ language plpgsql;

