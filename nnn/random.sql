-- nownownow.com/random
-- no body but keeping uniformity for post-processing
create function nnn.random(out head text, out body text) as $$
begin
	select concat(e'303\r\nLocation: ', long) into head
	from now_pages
	where checked_at > current_date - 180  -- less likely to be dead URL
	order by random() limit 1;
end;
$$ language plpgsql;
