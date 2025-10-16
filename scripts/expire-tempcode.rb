#!/usr/bin/env ruby
require 'pg'
db = PG::Connection.new(dbname: 'sivers', user: 'sivers')
db.exec("delete from temps where expires < now()")
