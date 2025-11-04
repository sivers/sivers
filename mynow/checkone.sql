-- get one site that needs checking (if claimed already!)
create function mynow.checkone(kk char(32), _nowpageid integer,
	out head text, out body text) as $$
declare
	r now_pages;
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
	body = o.template('mynow-wrap', 'mynow-check', jsonb_build_object(
		'id', r.id,
		'updated_at', r.updated_at,
		'updated_at2', to_char(r.updated_at, 'FMDD FMMonth YYYY'),
		'today', current_date,
		'long', r.long,
		'look4', r.look4
	));
end;
$$ language plpgsql;

