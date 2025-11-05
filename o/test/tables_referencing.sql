select plan(2);

select is(tablename, 'listpeople'),
	is(colname, 'list_id')
from o.tables_referencing('lists', 'id');
