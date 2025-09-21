-- How to have PostgreSQL know whether a photo exists on the filesystem?
--    At moment of upload (the only time the filesystem of webp images is changed), run a script to update the database to say what's there.
--    now_profiles.photo boolean
--    This happened in previous POST/upload so by the time this GET /photo comes, the DB itself will know if it's on the filesystem
-- At upload time, I call to PostgreSQL anyway with cookie for DB to tell filesystem what to name it, and update photo=true
-- also generate random string to bust cache of newly uploaded profile photo
create function mynow.photo(kki char(32),
	out head text, out body text) as $$
declare
	pid integer;
	data jsonb;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		data = to_jsonb(r) from (
			select public_id, photo, random_string(3) from now_profiles where id = pid
		) r;
		if data is null then  -- no profile? weird.
			head = e'303\r\nLocation: /f?m=uninvited';
		else
			body = o.template('mynow-headfoot', 'mynow-photo', data);
		end if;
	end if;
end;
$$ language plpgsql;

