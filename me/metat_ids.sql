-- ids for looping and passing to me.metat(id)

create function me.metat_ids() returns table(id integer) as $$
	select distinct(where_id) from meetings
	where whatime < now()
	and topics is not null
	order by where_id
$$ language sql;

