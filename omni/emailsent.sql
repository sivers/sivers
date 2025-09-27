-- used by SMTP server after email successfully sent
-- compartmentalized in function in case I change columns
create function o.emailsent(_id integer) returns void as $$
	update emails set outgoing = true where id = $1;
$$ language sql;
