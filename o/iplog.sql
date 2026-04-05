create function o.iplog(_pid integer, _ip inet) returns void as $$
	with existing as (
		select 1 from stats 
		where person_id = $1
		and statkey = 'ip' 
		and created_at > current_date - 30
	)
	insert into stats (person_id, statkey, statvalue)
	select $1, t.key, t.val
	from (
		select city, state, country::text as country
		from ips
		where range @> ($2 - '0.0.0.0'::inet)
	) i
	cross join lateral (values 
		('ip',      host(_ip)),
		('city',    i.city),
		('state',   i.state),
		('country', i.country)
	) as t(key, val)
	where t.val is not null
	and not exists (select 1 from existing);
$$ language sql;

