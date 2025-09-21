#!/usr/bin/env ruby
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

if File.exist?(ARGV[0])
  code = File.basename(ARGV[0])
  contents = File.read(ARGV[0])
  r = DB.exec("select template from templates where code = $1", [code])
  if r.ntuples == 0
    puts "adding #{code}"
    DB.exec("insert into templates (code, template) values ($1, $2)", [code, contents])
  elsif r[0]['template'] != contents
    puts "updating #{code}"
    DB.exec_params("update templates set template = $1 where code = $2", [contents, code])
  end
end

