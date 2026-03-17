-- update quantity of a lineitem, then redirect to view invoice again
create function storm.lineitem_update(kki char(32), lineid integer, quant integer,
	out head text, out body text) as $$
declare
	admin integer;
	invid integer;
begin
	-- first, web app auth
	select admin_auths.person_id into admin
	from logins
	join admin_auths on logins.person_id = admin_auths.person_id
	where logins.cookie = $1
	and admin_auths.appcode = 'storm';
	if admin is null then
		head = e'303\r\nLocation: /login';
		return;
	end if;
	-- update line quantity, getting its invoice_id after
	update lineitems
	set quantity = $3
	where id = $2
	returning invoice_id into invid;
	head = e'303\r\nLocation: /invoice/' || invid;
end;
$$ language plpgsql;


