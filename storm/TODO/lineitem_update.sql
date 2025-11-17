	update lineitems
	set quantity = $2
	where id = $1;
