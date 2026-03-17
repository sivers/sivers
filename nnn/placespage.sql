create function nnn.placespage(out body text) as $$
declare
	places jsonb;
begin
	select jsonb_agg(r) into places from (
		select name, url, count from nnn.places()
	) r;
	body = o.template('nnn-wrap', 'nnn-home', jsonb_build_object(
		'pagetitle', 'personal websites with a /now page',
		'date', current_date,
		'places', places));
end;
$$ language plpgsql;
