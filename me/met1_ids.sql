-- ids for looping and passing to me.met1(id)
--
-- this is for *all* meetings not just for one place,
-- since they all get written to disk as sive.rs/met/:id

create function me.met1_ids() returns setof integer as $$
	select id from meetings
	where whatime < now()
	and topics is not null
	and notes is not null
	order by id
$$ language sql;

