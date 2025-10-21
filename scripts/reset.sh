#!/bin/sh

dropdb siverstest
createdb -U sivers siverstest
psql --quiet -U sivers -d siverstest -f tables.sql
psql --quiet -U sivers -d siverstest -f table-refs.sql
psql --quiet -U sivers -d siverstest -c "create extension if not exists pgtap"

for dbname in `echo "sivers siverstest"`; do
	echo $dbname
	cmd="psql --quiet -U sivers -d $dbname"
	$cmd -c "set plpgsql.extra_warnings to 'all'"

	$cmd -c "drop schema if exists o cascade"
	$cmd -c "create schema o"
	for f in omni/*.sql; do
		$cmd -f $f
	done

	$cmd -c "drop schema if exists mynow cascade"
	$cmd -c "create schema mynow"
	$cmd -c "drop schema if exists nnn cascade"
	$cmd -c "create schema nnn"
	for f in nnn/*.sql; do
		$cmd -f $f
	done
done

