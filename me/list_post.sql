create function me.list_post(_pid integer, _lopass text, _listype text,
	out head text, out body text) as $$
declare
	pid integer;
	eml text;
begin
	select id into pid
	from people
	where id = $1 and lopass = $2;
	if pid is null then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	if ($3 != 'all' and $3 != 'some' and $3 != 'none') then
		head = e'303\r\nLocation: /contact';
		return;
	end if;

	-- form was submitted for a person but listype is per email address
	--
	-- some day, change this so /list shows all their email addresses. but until then:
	--
	-- assume newest is the one to change, and rest are 'none'
	select email into eml from o.email_for(pid);

	update ats
	set listype = 'none'
	where person_id = pid
	and email != eml;

	update ats
	set listype = $3, used = now()
	where email = eml;

	head = e'303\r\nLocation: /thanks?for=list';
end;
$$ language plpgsql;

