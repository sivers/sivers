create function o.admin_pass_set(_pid integer, _pass text) returns void as $$
	update admins
	set hashpass = crypt($2, gen_salt('bf', 8))
	where person_id = $1;
$$ language sql;

