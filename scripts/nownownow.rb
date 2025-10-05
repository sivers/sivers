# output nownownow.com static site
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

OUTDIR = '/var/www/html/nownownow.com/'

r = DB.exec("select body from nnn.placespage()")[0]
File.write(OUTDIR + 'index.html', r['body'])

DB.exec("select uri, body from nnn.placesout()").each do |r|
  File.write(OUTDIR + r['uri'], r['body'])
end

r = DB.exec("select body from nnn.random()")[0]
File.write(OUTDIR + 'random', r['body'])

r = DB.exec("select body from nnn.now()")[0]
File.write(OUTDIR + 'now', r['body'])

r = DB.exec("select body from nnn.about()")[0]
File.write(OUTDIR + 'about', r['body'])

r = DB.exec("select body from nnn.text()")[0]
File.write(OUTDIR + 'nownownow.txt', r['body'])

%x(mkdir -p #{OUTDIR}/p)
%x(rm -f #{OUTDIR}/p/????)
DB.exec("select uri, body from nnn.profiles()").each do |r|
  File.write(OUTDIR + 'p/' + r['uri'], r['body'])
end

