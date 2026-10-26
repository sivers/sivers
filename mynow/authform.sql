create function mynow.authform(kk char(32), message text,
	out head text, out body text) as $$
declare
	pid integer;
	data jsonb;
begin
	pid = mynow.auth($1);
	if pid is not null then
		head = e'303\r\nLocation: /';
	else
		if $2 = 'bad' then
			data = jsonb_build_object('message', 'Typo? Try again?');
		elsif $2 = '404' then
			data = jsonb_build_object('message', 'Not found here. Got a different email?');
		else
			data = jsonb_build_object('message', 'Your email address?');
		end if;
		body = o.template('mynow-wrap', 'mynow-authform', data);
	end if;
end;
$$ language plpgsql;

