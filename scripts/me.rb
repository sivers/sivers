#!/usr/bin/env ruby
# output sive.rs static site
require 'pg'
db = PG::Connection.new(dbname: 'sivers', user: 'sivers')

outdir = '/var/www/html/sive.rs/'

db.exec("select uri from me.article_uris()").each do |o|
  uri = o['uri']
  r = db.exec("select body from me.article(#{uri})")[0]
  File.write(outdir + uri, r['body'])
end

r = db.exec("select body from me.articles()")[0]
File.write(outdir + 'blog', r['body'])

r = db.exec("select body from me.articles_tagged('tech')")[0]
File.write(outdir + 'tech', r['body'])

%x(mkdir -p #{outdir}/book)
db.exec("select uri from me.book_uris()").each do |o|
  uri = o['uri']
  r = db.exec("select body from me.book(#{uri})")[0]
  File.write(outdir + 'book/' + uri, r['body'])
end

r = db.exec("select body from me.books()")[0]
File.write(outdir + 'book/index.html', r['body'])

r = db.exec("select body from me.home()")[0]
File.write(outdir + 'index.html', r['body'])

db.exec("select uri from me.interview_uris()").each do |o|
  uri = o['uri']
  r = db.exec("select body from me.interview(#{uri})")[0]
  File.write(outdir + uri, r['body'])
end

r = db.exec("select body from me.interviews()")[0]
File.write(outdir + 'i', r['body'])

%x(mkdir -p #{outdir}/met)
r = db.exec("select body from me.met()")[0]
File.write(outdir + 'met/index.html', r['body'])

db.exec("select id from me.met1_ids()").each do |o|
  id = o['id']
  r = db.exec("select body from me.met1(#{id})")[0]
  File.write(outdir + 'met/' + id, r['body'])
end

db.exec("select id from me.metat_ids()").each do |o|
  id = o['id']
  r = db.exec("select body from me.metat(#{id})")[0]
  File.write(outdir + 'met/at-' + id, r['body'])
end

db.exec("select uri, pagetitle from me.pages()").each do |o|
  r = db.exec_params("select body from me.page($1, $2)", [o['uri'], o['pagetitle']])[0]
  File.write(outdir + o['uri'], r['body'])
end

db.exec("select uri from me.presentation_uris()").each do |o|
  uri = o['uri']
  r = db.exec("select body from me.presentation(#{uri})")[0]
  File.write(outdir + uri, r['body'])
end
r = db.exec("select body from me.refs()")[0]
File.write(outdir + 'ref', r['body'])

