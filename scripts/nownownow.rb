# output nownownow.com static site
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

OUTDIR = '/var/www/html/nownownow.com/'

r = DB.exec("select body, urls from nnn.places()")[0]
File.open(OUTDIR + 'index.html', 'w') {|f| f.puts r['body'] }
PG::TextDecoder::Array.new.decode(r['urls']).each do |url|
  r = DB.exec("select body from nnn.place('#{url}')")[0]
  File.open(OUTDIR + url, 'w') {|f| f.puts r['body'] }
end

r = DB.exec("select body from nnn.random()")[0]
File.open(OUTDIR + 'random', 'w') {|f| f.puts r['body'] }

r = DB.exec("select body from nnn.now()")[0]
File.open(OUTDIR + 'now', 'w') {|f| f.puts r['body'] }

r = DB.exec("select body from nnn.text()")[0]
File.open(OUTDIR + 'nownownow.txt', 'w') {|f| f.puts r['body'] }

%x(mkdir -p #{OUTDIR}/p)
%x(rm -f #{OUTDIR}/p/????)
DB.exec("select uri, body from nnn.profiles()").each do |r|
  File.open(OUTDIR + 'p/' + r['uri'], 'w') {|f| f.puts r['body'] }
end

