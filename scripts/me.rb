#!/usr/bin/env ruby
# output sive.rs static site
require 'cgi'
require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

ODIR = '/var/www/html/sive.rs/' 
FDIR = '/home/derek/code/b/public/sive.rs/'
%x(rsync -a #{FDIR}* #{ODIR})

# blog body can have this line:
# <!-- CODE: filename.here -->
# replace with HTML of that code from code/
def code_replace(body)
  return body unless body.include?('<!-- CODE: ')
  r = %r{<!-- CODE: (\S+) -->}
  codedir = ODIR + 'code/'
  newbody = ''
  body.split("\n").each do |line|
    m = r.match(line.strip)
    unless m
      newbody << (line + "\n")
    else
      filename = m[1]
      raise "code missing: #{filename}" unless File.exist?(codedir + filename)
      # first line of code is credit pointing to article URL
      code = File.readlines(codedir + filename)[1..-1].join('').strip
      newbody << '<div class="code">'
      newbody << "\n<pre><code>"
      newbody << CGI.escapeHTML(code)
      newbody << "\n</code></pre>"
      newbody << '<small><a href="/code/%s">download code</a></small>' % filename;
      newbody << "\n</div>\n"
    end
  end
  newbody
end

def q2o(from, uri)
  html = DB.exec("select body from me.#{from}")[0]['body']
  canon = '<link rel="canonical" href="https://sive.rs/%s">' % (uri == 'index.html' ? '' : uri)
  html.gsub!(/^<title>/, canon + "\n<title>")
  File.write(ODIR + uri, code_replace(html))
end

DB.exec("select uri from me.article_uris()").each do |o|
  q2o("article('%s')" % o['uri'], o['uri'])
end

q2o("articles()", "blog")

# excluding metabook pages since they are still static
DB.exec("select uri from topics where uri not in (select uri from metabooks)").each do |o|
  q2o("topic_page('%s')" % o['uri'], o['uri'])
end

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

