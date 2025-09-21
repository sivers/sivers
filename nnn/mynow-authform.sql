create function mynow.authform(kki char(32), message text,
	out head text, out body text) as $$
declare
	pid integer;
	data jsonb;
begin
	perform 1 from logins where cookie = $1;
	if found then
		head = e'303\r\nLocation: /';
	else
		if $2 = 'bad' then
			data = jsonb_build_object('message', 'Typo? Try again?');
		elsif $2 = '404' then
			data = jsonb_build_object('message', 'Not found here. Got a different email?');
		else
			data = jsonb_build_object('message', 'Your email address?');
		end if;
		body = o.template('mynow-headfoot', 'mynow-authform', data);
	end if;
end;
$$ language plpgsql;

