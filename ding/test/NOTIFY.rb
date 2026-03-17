#!/usr/bin/env ruby

# can't test notify/listen with pgTAP so here's a manual test:

require 'pg'
db1 = PG.connect(dbname: 'siverstest', user: 'sivers')
db2 = PG.connect(dbname: 'siverstest', user: 'sivers')

db1.exec('listen tweet')
db1.exec('listen now_page')
db1.exec('listen audio')
db1.exec('listen article')
db1.exec('listen interview')
db1.exec('listen email')
db1.exec('listen ebook')
stop = false
listener = Thread.new do
  until stop
    db1.wait_for_notify(1) do |event, pid, payload|
      puts "OK event=%s payload=%s" % [event, payload]
    end
  end
end

db2.exec("insert into people (id, name) values (1, 'tester')")

# TWEET
print "tweet insert\t\t"
db2.exec("insert into tweets (message) values ('ok')")
sleep 0.1
db2.exec("delete from tweets")

# NOW PAGE
print "now_page insert\t\t"
db2.exec("insert into now_pages (person_id, short, long) values (1, 'o.k/now', 'https://o.k/now')")
sleep 0.1
db2.exec("delete from now_pages")

# AUDIO
puts "audio insert...."
db2.exec("insert into audios (filename) values ('one.mp3')")
sleep 0.1
print "audio update\t\t"
db2.exec("update audios set bytes=123, seconds=123 where filename='one.mp3'")
sleep 0.1
print "audio insert\t\t"
db2.exec("insert into audios (filename, bytes, seconds) values ('two.mp3', 234, 234)")
sleep 0.1
db2.exec("delete from audios")

# ARTICLE
puts "article insert...."
db2.exec("insert into articles (uri, title, original) values ('one', 'One', 'Just one.')")
sleep 0.1
print "article update\t\t"
db2.exec("update articles set posted='2026-01-01' where uri='one'")
sleep 0.1
print "article insert\t\t"
db2.exec("insert into articles (uri, title, original, posted) values ('two', 'Two', 'Both now.', '2026-02-02')")
sleep 0.1
db2.exec("delete from articles")

# INTERVIEW
puts "interview insert...."
db2.exec("insert into interviews (name) values ('a podcast')")
sleep 0.1
print "interview update\t"
db2.exec("update interviews set uri='one' where name='a podcast'")
sleep 0.1
print "interview insert\t"
db2.exec("insert into interviews (name, uri) values ('two ferns', 'two')")
sleep 0.1
db2.exec("delete from interviews")

# EMAIL
puts "email insert...."
db2.exec("insert into emails (person_id, category, created_by, their_email, their_name, subject, body, outgoing) values
         (1, 'in', 1, 'x@x.x', 'X Name', 'in subject', 'in body', false)")
sleep 0.1
print "email insert\t\t"
db2.exec("insert into emails (person_id, category, created_by, their_email, their_name, subject, body, outgoing) values
         (1, 'out', 1, 'x@x.x', 'X Name', 'out subject', 'out body', null)")
sleep 0.1
db2.exec("delete from emails")

# EBOOK
puts "ebook insert...."
db2.exec("insert into ebooks (code, title, author, read, rating) values ('a', 'A Title', 'An Author', '2026-03-03', 10)")
sleep 0.1
print "ebook update\t\t"
db2.exec("update ebooks set summary='great' where code='a'")
sleep 0.1
print "ebook insert\t\t"
db2.exec("insert into ebooks (code, title, author, read, rating, summary) values ('b', 'B Title', 'B Author', '2026-03-05', 5, 'B summary')")
sleep 0.1
db2.exec("delete from ebooks")



# cleanup and END
db2.exec("delete from people")
stop = true
puts "\n--------------------"
db2.exec("notify tweet, 'THE END'")
listener.join

