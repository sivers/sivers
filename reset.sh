#!/bin/sh

dropdb siverstest
createdb -U sivers siverstest
psql --quiet -U sivers -d siverstest -f tables.sql
awk -f table-refs.awk tables.sql > /tmp/table-refs.sql
psql --quiet -U sivers -d siverstest -f /tmp/table-refs.sql
psql --quiet -U sivers -d siverstest -c "create extension if not exists pgtap"

for dbname in sivers siverstest; do
	echo $dbname
	cmd="psql --quiet -U sivers -d $dbname"
	$cmd -c "set plpgsql.extra_warnings to 'all'"

	for schema in o mynow nnn peep fed storm; do
		echo "\t$schema"
		$cmd -c "set client_min_messages to warning; drop schema if exists $schema cascade"
		$cmd -c "create schema $schema"
		for f in "$schema"/*.sql; do
			$cmd -f $f
		done
	done

done

