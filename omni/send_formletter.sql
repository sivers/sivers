-- to this person, send this formletter, which must have a subject
create function o.send_formletter(_pid integer, _formid integer) returns integer as $$
	select o.email(0, $1,
		(select o.ebodyparse((
			select subject from formletters where id = $2), $1
		)), (select o.ebodyparse((
			select body from formletters where id = $2), $1
		)),
	null);
$$ language sql;
