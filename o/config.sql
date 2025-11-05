create function o.config(_key text) returns text as $$
	select v from configs where k = $1;
$$ language sql stable;

