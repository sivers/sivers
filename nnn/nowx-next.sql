-- get next site that needs checking
-- claim it temporarily to prevent two people checking same site simultaneously
-- no body. only redirect to now_pages.id checking after claiming
create or replace function nowx.next(kki char(32),
	out head text, out body text) as $$
declare
	pid integer;
	pageid smallint;
begin
	select logins.person_id into pid
	from logins
	join now_pages on logins.person_id = now_pages.person_id
	where logins.cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
		return;
	end if;
	-- caveat! if this person already has one open, return that
	select id into pageid
	from now_pages
	where review_by = pid;
	-- nope? claim next one
	if pageid is null then
		with nextpage as (
			select id
			from now_pages
			where review_at is null
			order by checked_at, id
			for update skip locked
			limit 1
		)
		update now_pages
		set review_at = now(), review_by = pid
		from nextpage
		where nextpage.id = now_pages.id
		returning now_pages.id into pageid;
	end if;
	if pageid is null then
		-- all 5000+ pages are being reviewed at once? really?
		head = e'303\r\nLocation: /';
	else
		-- go to /check/123 to do the checks
		head = e'303\r\nLocation: /check/' || pageid;
	end if;
end;
$$ language plpgsql;

