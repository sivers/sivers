create function stork.person_login(_pid integer,
	out head text, out body text) as $$
declare
	t char(16);
begin
	select temp into t from o.temp_add($1);
	head = e'303\r\nLocation: https://sivers.com/e?t=' || t;
end;
$$ language plpgsql;

