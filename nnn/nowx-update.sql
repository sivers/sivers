-- update look4, long, or updated_at - then return to check page for this ID
create or replace function nowx.update(kki char(32), _pageid integer, _updates jsonb,
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
		head = e'303\r\nLocation: /f';
		return;
	end if;
	head = e'303\r\nLocation: /check/' || $2;

	if btrim($3 ->> 'long') ~ '^https?://[^/]+\..+' then
		if btrim($3 ->> 'long') != r.long and length($3 ->> 'long') < 99 then
			update now_pages
			set long = btrim($3 ->> 'long')
			where id = $2;
		end if;
	end if;

	if length(coalesce($3 ->> 'look4', '')) between 4 and 50 then
		update now_pages
		set look4 = btrim($3 ->> 'look4')
		where id = $2;
	end if;

	if $3 ->> 'updated_at' ~ '^2[0-9]{3}-[0-9]{2}-[0-9]{2}$' then
		if ($3 ->> 'updated_at')::date != r.updated_at then
			update now_pages
			set updated_at = ($3 ->> 'updated_at')::date
			where id = $2;
		end if;
	end if;
end;
$$ language plpgsql;

