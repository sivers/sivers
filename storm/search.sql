create or replace function storm.search(_q text,
	out head text, out body text) as $$
declare
	q text;
	found jsonb;
begin
	q = concat('%', btrim($1, e'\t\r\n '), '%');
	if length(q) > 4 then
		found = coalesce((select jsonb_agg(r) from (
			select people.id, people.name,
			string_agg(ats.email, ',') as emails
			from people
			left join ats on people.id = ats.person_id
			where (people.name ilike q or company ilike q or ats.email ilike q)
			and people.id in (
				select person_id from invoices
			)
			group by people.id, people.name
			order by people.name, people.id
		) r), '[]');
	end if;
	body = o.template('storm-wrap', 'storm-search', jsonb_build_object('found', found));
end;
$$ language plpgsql;

