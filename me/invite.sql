create function me.invite(_code char(8), _project varchar(8),
	out head text, out body text) as $$
declare
	pid integer;
begin
	update invites
	set used = now()
	where code = $1
	and project = $2
	and used is null
	returning person_id into pid;

	if pid is null then
		head = '404';
		return;
	end if;
	head = '202';

	-- assumes I'll do something about it here. maybe NOTIFY?
end;
$$ language plpgsql;

