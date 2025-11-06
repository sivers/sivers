#!/usr/bin/env ruby
# output nownownow.com static site
require 'pg'
db = PG::Connection.new(dbname: 'sivers', user: 'sivers')

outdir = '/var/www/html/nownownow.com/'

r = db.exec("select body from nnn.placespage()")[0]
File.write(outdir + 'index.html', r['body'])

db.exec("select uri, body from nnn.placesout()").each do |r|
  File.write(outdir + r['uri'], r['body'])
end

r = db.exec("select body from nnn.random()")[0]
File.write(outdir + 'random', r['body'])

r = db.exec("select body from nnn.now()")[0]
File.write(outdir + 'now', r['body'])

r = db.exec("select body from nnn.about()")[0]
File.write(outdir + 'about', r['body'])

r = db.exec("select body from nnn.text()")[0]
File.write(outdir + 'nownownow.txt', r['body'])

%x(mkdir -p #{outdir}/p)
%x(rm -f #{outdir}/p/????)
db.exec("select uri, body from nnn.profiles()").each do |r|
  File.write(outdir + 'p/' + r['uri'], r['body'])
end

