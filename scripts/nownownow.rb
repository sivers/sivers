# output nownownow.com static site
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

OUTDIR = '/var/www/html/nownownow.com/'

body = DB.exec("select body from nnn.places()")[0]['body']
File.open(OUTDIR + 'index.html', 'w') {|f| f.puts body }

urls = PG::TextDecoder::Array.new.decode(DB.exec("select urls from nnn.places()")[0]['urls'])
urls.each do |url|
  body = DB.exec("select body from nnn.place('#{url}')")[0]['body']
  File.open(OUTDIR + url, 'w') {|f| f.puts body }
end

body = DB.exec("select body from nnn.random()")[0]['body']
File.open(OUTDIR + 'random', 'w') {|f| f.puts body }

body = DB.exec("select body from nnn.now()")[0]['body']
File.open(OUTDIR + 'now', 'w') {|f| f.puts body }

body = DB.exec("select body from nnn.text()")[0]['body']
File.open(OUTDIR + 'nownownow.txt', 'w') {|f| f.puts body }

