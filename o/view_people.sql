-- should views go here or somewhere else?
-- it's very omni, used in a few places

create view o.view_people as
select p.id, p.name, p.company, p.email_count, p.city, p.state, p.country,
string_agg(ats.email, ',') as emails
from people p
left join ats on p.id = ats.person_id
group by p.id, p.name, p.company, p.email_count, p.city, p.state, p.country
order by p.email_count desc, p.id desc;

