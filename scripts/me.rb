#!/usr/bin/env ruby
# output sive.rs static site
require 'fileutils'
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

ODIR = '/var/www/html/sive.rs/' 
FDIR = File.expand_path('../me-files/', __FILE__) + '/'
%w(style.css c.js favicon.ico ti.sh).each do |fn|
  FileUtils.cp(FDIR + fn, ODIR + fn)
end

def q2o(from, uri)
  html = DB.exec("select body from me.#{from}")[0]['body']
  canon = '<link rel="canonical" href="https://sive.rs/%s">' % (uri == 'index.html' ? '' : uri)
  html.gsub!(/^<title>/, canon + "\n<title>")
  File.write(ODIR + uri, html)
end

DB.exec("select uri from me.article_uris()").each do |o|
  q2o("article('%s')" % o['uri'], o['uri'])
end

q2o("articles()", "blog")

q2o("articles_tagged('tech')", "tech")

%x(mkdir -p #{ODIR}/book)
DB.exec("select uri from me.book_uris()").each do |o|
  q2o("book('%s')" % o['uri'], "book/%s" % o['uri'])
end

q2o("books()", "book/index.html")

q2o("home()", "index.html")

DB.exec("select uri from me.interview_uris()").each do |o|
  q2o("interview('%s')" % o['uri'], o['uri'])
end

q2o("interviews()", "i")

%x(mkdir -p #{ODIR}/met)
q2o("met()", "met/index.html")

DB.exec("select id from me.met1_ids()").each do |o|
  q2o("met1(%d)" % o['id'], "met/%d" % o['id'])
end

DB.exec("select id from me.metat_ids()").each do |o|
  q2o("metat(%d)" % o['id'], "met/at-%d" % o['id'])
end

DB.exec("select uri, pagetitle from me.pages()").each do |o|
  q2o("page('%s', '%s')" % [o['uri'], o['pagetitle']], o['uri'])
end

DB.exec("select uri from me.presentation_uris()").each do |o|
  q2o("presentation('%s')" % o['uri'], o['uri'])
end

q2o("presentations()", "presentations")

q2o("refs()", "ref")

q2o("tweets()", "d")

q2o("sitemap()", "sitemap.xml")

