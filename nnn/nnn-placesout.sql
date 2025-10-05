-- all places! returns table not value. loop through results to write to disk
create function nnn.placesout() returns table (uri text, body text) as $$
	select url, nnn.place(country, state) from nnn.places();
$$ language sql;
