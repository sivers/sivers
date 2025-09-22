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
# TODO:
DB.exec("select public_id, now_profiles.title, liner, why, thought, red,
people.name, people.city, people.state, countries.name as country,
-- ARRAY: select long, short from now_pages where person_id = 3
-- ARRAY: select url from urls where person_id = 3 order by main desc nulls last, id;
from now_profiles
join people on now_profiles.id = people.id
join countries on people.country = countries.code
join now_pages on now_profiles.id = now_pages.person_id
join urls on now_profiles.id = urls.person_id
where now_profiles.photo is true
order by now_profiles.public_id")

