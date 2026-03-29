#!/usr/bin/env ruby
# output sive.rs static site
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

ODIR = '/var/www/html/sive.rs/' 

def q2o(from, uri)
  html = DB.exec("select body from #{from}")[0]['body']
  File.write(ODIR + uri, html)
end

DB.exec("select uri from me.article_uris()").each do |o|
  q2o("me.article('%s')" % o['uri'], o['uri'])
end

q2o("me.articles()", 'blog')

q2o("me.articles_tagged('tech')", 'tech')

%x(mkdir -p #{ODIR}/book)
DB.exec("select uri from me.book_uris()").each do |o|
  q2o("me.book('%s')" % o['uri'], 'book/' + o['uri'])
end

q2o("me.books()", 'book/index.html')

q2o("me.home()", 'index.html')

DB.exec("select uri from me.interview_uris()").each do |o|
  q2o("me.interview('%s')" % o['uri'], o['uri'])
end

q2o("me.interviews()", 'i')

%x(mkdir -p #{ODIR}/met)
q2o("me.met()", 'met/index.html')

DB.exec("select id from me.met1_ids()").each do |o|
  q2o("me.met1(%d)" % o['id'], 'met/' + o['id'])
end

DB.exec("select id from me.metat_ids()").each do |o|
  q2o("me.metat(%d)" % o['id'], 'met/at-' + o['id'])
end

DB.exec("select uri, pagetitle from me.pages()").each do |o|
  q2o("me.page('%s', '%s')" % [o['uri'], o['pagetitle']], o['uri'])
end

DB.exec("select uri from me.presentation_uris()").each do |o|
  q2o("me.presentation('%s')" % o['uri'], o['uri'])
end

q2o("me.refs()", 'ref')

