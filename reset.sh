#!/bin/sh

# "sivers" = my live production database.
# Data and tables never dropped or changed here!
# Data and tables are not in one of my schemas, just top-level "public".
# Drop functions anytime (by dropping their whole schema) and reload.
# For "sivers", this reset.sh ONLY DROPS AND RELOADS THE FUNCTIONS.
# It is OK TO RUN ON THE LIVE PRODUCTION SERVER.

# "siverstest" = a clone of sivers, for testing.
# It has no data. It doesn't even exist on the live server.
# Data is inserted (then reverted) by tests in /{schema}/test/*.sql
# For "siverstest", this reset.sh drops and completely rebuilds everything.

dropdb -U sivers siverstest
createdb -U sivers siverstest
psql --quiet -U sivers -d siverstest -f tables.sql
awk -f scripts/table-refs.awk tables.sql > /tmp/table-refs.sql
psql --quiet -U sivers -d siverstest -f /tmp/table-refs.sql
psql --quiet -U sivers -d siverstest -c "create extension if not exists pgtap"

for dbname in sivers siverstest; do
	echo $dbname
	cmd="psql --quiet -U sivers -d $dbname"
	$cmd -c "set plpgsql.extra_warnings to 'all'"

	for schema in o ding me mynow nnn stork; do
		echo "\t$schema"
		$cmd -c "set client_min_messages to warning; drop schema if exists $schema cascade"
		$cmd -c "create schema $schema"
		for f in "$schema"/*.sql; do
			$cmd -f $f
		done
	done

done

