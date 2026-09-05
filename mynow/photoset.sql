-- Router tells PostgreSQL it has the photo uploaded for this cookie
-- PG updates photo=yes for this cookie's profile,
-- and returns public_id code so Router knows how to name the file
create function mynow.photoset(kk char(32), out code char(4)) as $$
begin
	select public_id into code
	from logins
	join now_profiles on logins.person_id = now_profiles.id
	where logins.cookie = $1;
	update now_profiles set photo = true where public_id = code;
end;
$$ language plpgsql; -- TODO change to language sql and void return because the 'code' variable not needed by router anymore
