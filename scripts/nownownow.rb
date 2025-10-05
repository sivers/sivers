# output nownownow.com static site
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

OUTDIR = '/var/www/html/nownownow.com/'

r = DB.exec("select body from nnn.placespage()")[0]
File.write(OUTDIR + 'index.html', r['body'])

PG::TextDecoder::Array.new.decode(r['urls']).each do |url|
  r = DB.exec("select body from nnn.place('#{url}')")[0]
  File.write(OUTDIR + url, r['body'])
end
DB.exec("select uri, body from nnn.placepages()").each do |r|
  File.write(OUTDIR + 'p/' + r['uri'], r['body'])
end

r = DB.exec("select body from nnn.random()")[0]
File.write(OUTDIR + 'random', r['body'])

r = DB.exec("select body from nnn.now()")[0]
File.write(OUTDIR + 'now', r['body'])

r = DB.exec("select body from nnn.text()")[0]
File.write(OUTDIR + 'nownownow.txt', r['body'])

%x(mkdir -p #{OUTDIR}/p)
%x(rm -f #{OUTDIR}/p/????)
DB.exec("select uri, body from nnn.profiles()").each do |r|
  File.write(OUTDIR + 'p/' + r['uri'], r['body'])
end

