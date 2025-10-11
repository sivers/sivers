#!/usr/bin/env ruby
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

template_file_codes = []
TDIR = File.expand_path('../..', __FILE__) + '/templates/'

# import templates from files into database
Dir[TDIR + '*.html'].each do |fullpath|
  code = File.basename(fullpath, '.html')
  contents = File.read(fullpath).strip
  r = DB.exec("select template from templates where code = $1", [code])
  if r.ntuples == 0
    puts "adding #{code}"
    DB.exec("insert into templates (code, template) values ($1, $2)", [code, contents])
  elsif r[0]['template'] != contents
    puts "updating #{code}"
    DB.exec("update templates set template = $1 where code = $2", [contents, code])
  end
  template_file_codes << code
end

# any in database not in files?
DB.exec("select code, template from templates where code not in ('%s')" % template_file_codes.join("','")).each do |r|
  outfile = "/tmp/%s.html" % r['code']
  File.write(outfile, r['template'])
  puts "IN DATABASE NOT FILES: #{outfile}"
end

