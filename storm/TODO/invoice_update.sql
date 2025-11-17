	-- blacklist cols are calculated
	perform f.update_black('invoices', $1, $2, '{id,created,total,code,shipcost}', '{add2,shipdate}');
