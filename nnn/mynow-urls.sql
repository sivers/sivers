create function mynow.urls(kki char(32),
	out head text, out body text) as $$
declare
	pid integer;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		body = o.template('mynow-wrap', 'mynow-urls', 
			jsonb_build_object('urls', coalesce((select jsonb_agg(r) from (
				select id, main, url
				from urls where person_id = pid
				order by main desc nulls last, id asc
			) r), '[]'))
		);
	end if;
end;
$$ language plpgsql;

