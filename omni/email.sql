-- INSERT OUTGOING EMAIL into the database, adding greeting and signature.
-- if it's a reference to another email, include that emails.id as _ref (5th arg)
-- if it's a new email, leave _ref as NULL
create function o.email(_from integer, _to integer, _subj text, _body text, _ref integer,
	out id integer) as $$
declare
	body text;
	tcat varchar(16);
	tname text;
	temail text;
begin
	-- combine parsed greeting, _body, and sig into new body
	select o.ebodyparse(concat(e'Hi {greeting} -\n\n', $4, e'\n\n--\n', v), $2)
	into body
	from configs
	where k = 'sig';
	-- if new email, use newest email address
	if $5 is null then
		select people.name, o.email_for(people.id), 'out'
		into tname, temail, tcat
		from people
		where people.id = $2;
	else -- if it's a reply, use address of email I'm replying to
		select people.name, emails.their_email, emails.category
		into tname, temail, tcat
		from emails
		join people on emails.person_id = people.id
		where emails.id = $5;
	end if;
	insert into emails (person_id, category,
		created_at, created_by, opened_at, opened_by, closed_at, closed_by,
		reference_id, their_email, their_name, subject, body, outgoing)
	values ($2, tcat,
		now(), $1, now(), $1, now(), $1,
		$5, temail, tname, $3, body, null)
	returning emails.id into email.id;
end;
$$ language plpgsql;
