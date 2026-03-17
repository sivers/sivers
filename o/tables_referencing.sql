-- used for updating foreign keys

-- params: a column name, in two parts:
--	1: table name
--	2: column name
-- returns: a list of tables referencing that column
--	tablename: text like 'translators'
--	colname: text like 'person_id'
create function o.tables_referencing(_table text, _column text)
returns table(tablename text, colname text) as $$
	select k.relname::text, a.attname::text
	from pg_constraint c
	join pg_class k on c.conrelid = k.oid
	join pg_attribute a on c.conrelid = a.attrelid
	join pg_namespace n on k.relnamespace = n.oid
	where c.confrelid = (
		select oid from pg_class
		where relname = $1
	)
	and array[a.attnum] <@ c.conkey
	and c.confkey @> (
		select array_agg(attnum)
		from pg_attribute
		where attname = $2
		and attrelid = c.confrelid
	)
	order by k.relname;
$$ language sql;
