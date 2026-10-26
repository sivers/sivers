#!/usr/bin/env ruby
# Sync templates between database and disk
#
# First write ALL templates to /tmp/templates/{code} if nothing there
#
# Run again. If there is something there and it's different?
# Update the database with the updated file.
TDIR = "/tmp/templates"
require 'fileutils'
require 'pg'
if '' != `pgrep -f "[s]sh -L 5433"`
  DB = PG::Connection.new(dbname: 'sivers', user: 'sivers', port: 5433, host: '127.0.0.1')
else
  DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')
end

FileUtils.mkdir_p(TDIR)

DB.exec("select code, template from templates order by code").each do |r|
  filepath = "#{TDIR}/#{r['code']}"
  if FileTest.exist?(filepath)
    contents = File.read(filepath).strip
    if contents != r['template'].strip
      puts filepath
      DB.exec_params("update templates set template = $1 where code = $2", [contents, r['code']])
    end
  else
    File.write(filepath, r['template'])
  end
end

