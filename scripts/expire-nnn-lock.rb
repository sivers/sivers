#!/usr/bin/env ruby
require 'pg'
db = PG::Connection.new(dbname: 'sivers', user: 'sivers')
db.exec("update now_pages set review_at = null, review_by = null where review_at < now () - interval '12 hours'")
