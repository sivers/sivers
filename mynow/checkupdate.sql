-- update look4 and updated_at 
-- then send formletter based on age
-- then redirect to next /check
create function mynow.checkupdate(kk char(32), _pageid integer, _look4 text, _upd8 date,
	out head text, out body text) as $$
declare
	r now_pages;
	pid integer;
begin
	-- only if this person has already claimed this now_page for review
	select now_pages.* into r
	from logins
	join now_pages on logins.person_id = now_pages.review_by
	where logins.cookie = $1
	and now_pages.id = $2;
	if r is null then
		head = e'303\r\nLocation: /check';
		return;
	end if;
	pid = r.review_by; -- initial 'into r' statement missed pid

	-- optional update
	if $4 > r.updated_at then
		update now_pages set updated_at = $4 where id = $2;
	end if;

	-- look4 is required update: so if matches (4<>50)...
	if length($3) between 4 and 50 then
		-- update & review is done
		update now_pages set look4 = btrim($3),
		review_at = null, review_by = null, 
		checked_at = now(), checked_by = pid
		where id = $2;
		-- send formletter based on $4 date 
		if $4 < current_date - interval '2 years' then
			-- "your page is old"
			perform o.send_formletter(r.person_id, 22);
		else
			-- "your page is good"
			perform o.send_formletter(r.person_id, 23);
		end if;
		-- on to the next!
		select x.head into head from mynow.checknext($1) x;
	else
		-- look4 must be too short or long, so send them back
		head = e'303\r\nLocation: /check/' || $2;
	end if;
exception when others then
	-- error? send them back
	head = e'303\r\nLocation: /check/' || $2;
end;
$$ language plpgsql;

