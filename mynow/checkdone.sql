-- action options: 'nodate', 'gone'
-- no body, head always redirect
create function mynow.checkdone(kk char(32), _pageid integer, action text,
	out head text, out body text) as $$
declare
	pid integer;
	r now_pages;
begin
	pid = mynow.auth($1);
	if pid is null then
		head = e'303\r\nLocation: /f';
		return;
	end if;
	-- only if this person has already claimed this now_page for review
	select now_pages.* into r
	from now_pages
	where now_pages.review_by = pid
	and now_pages.id = $2;
	if r is null then
		head = e'303\r\nLocation: /f';
		return;
	end if;
	if $3 is null or $3 not in ('nodate', 'gone') then
		head = e'303\r\nLocation: /check/' || $2;
		return;
	end if;
	case $3
	when 'nodate' then
		perform o.send_formletter(r.person_id, 21);
	when 'gone' then
		perform o.send_formletter(r.person_id, 24);
		update now_pages set flagged = true where id = $2;
	end case;
	-- for all actions, review is complete
	update now_pages
	set review_at = null, review_by = null, 
	checked_at = now(), checked_by = pid
	where id = $2;

	-- get next page to check
	select x.head into head from mynow.checknext($1) x;
end;
$$ language plpgsql;
