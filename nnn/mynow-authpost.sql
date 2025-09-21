create function mynow.authpost(kki char(32), _email text,
	out head text, out body text) as $$
declare
	em text;
	pid integer;
	tempcode char(16);
begin
	em = o.clean_email($2);
	-- has correct cookie already? send home
	perform 1 from logins where cookie = $1;
	if found then
		head = e'303\r\nLocation: /';
	-- badly formed email? send to /f?m=bad
	elsif em !~ '^\S+@\S+\.\S+$' then
		head = e'303\r\nLocation: /f?m=bad';
	else
		-- email not found? send to /f?m=404
		perform 1 from ats where email = em;
		if not found then
			head = e'303\r\nLocation: /f?m=404';
		else
			select now_pages.person_id into pid
			from ats
			join now_pages on ats.person_id = now_pages.person_id
			where ats.email = em;
			-- email not in mynow? show uninvited message
			if pid is null then
				body = o.template('mynow-headfoot', 'mynow-uninvited', null);
			else
				-- email found! give tempcode to tell router to send email, and show message
				-- update email used so this one is most recent, and gets email
				update ats set used = now() where email = em;
				select temp into tempcode from o.temp_add(pid);
				if tempcode is not null then
					perform o.temp_email(tempcode, 'my.nownownow.com');
					-- NOTE: ROUTER NEEDS TO SEND NEWEST EMAILS NOW!
				end if;
				body = o.template('mynow-headfoot', 'mynow-checkemail', null);
			end if;
		end if;
	end if;
end;
$$ language plpgsql;

