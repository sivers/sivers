require 'pg'
if '' != `pgrep -f "[s]sh -L 5433"`
  DB = PG::Connection.new(dbname: 'sivers', user: 'sivers', port: 5433, host: '127.0.0.1')
else
  DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')
end

raise 'filename after' unless ARGV[0] && File.exist?(ARGV[0])
uri = File.basename(ARGV[0])
lines = File.readlines(ARGV[0])
title = lines.shift.gsub('title: ', '').strip
posted = lines.shift.gsub('date: ', '').strip
original = lines.join("\n").strip

DB.exec("select uri, name from topics order by sortid").each do |r|
  puts "%s\t%s" % [r['uri'], r['name']]
end
print "WHICH TOPIC? "
topic = STDIN.gets.strip

r = DB.exec_params("insert into articles (uri, posted, title, original, topic) values ($1, $2, $3, $4, $5) returning id", [uri, posted, title, original, topic])
puts "done. Article# %d" % r[0]['id']

