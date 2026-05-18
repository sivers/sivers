-- To drop the indexes I have created, use /o /tmp/drop.sql then run this
-- Then edit the /tmp/drop.sql output file to make sure, then load it.
-- 
-- Then grep 'create index' in ../tables.sql > /tmp/newindex.sql and create anew.

select 'drop index if exists ' || quote_ident(n.nspname) || '.' || quote_ident(i.relname) || ';' as drop_command
from pg_class i
join pg_index idx on i.oid = idx.indexrelid
join pg_namespace n on i.relnamespace = n.oid
where i.relkind = 'i' 
and n.nspname not in ('pg_catalog', 'information_schema', 'pg_toast')
and not idx.indisprimary 
and not idx.indisunique;
