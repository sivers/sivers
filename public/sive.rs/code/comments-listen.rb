#!/usr/bin/env ruby  # static HTML comments, by Derek Sivers. Article: https://sive.rs/shc

require 'pg'
DB = PG::Connection.new(dbname: 'test', user: 'tester')
BASEDIR = '/var/www/htdocs/commentcache/' # directory in your web root

# a single comment list entry, used in ol map, below
def li(row)
  '<li><cite>%s (%s)</cite><p>%s</p></li>' %
    [row['name'], row['created_at'], row['comment']]
end

# top-level map of database rows into HTML list
def ol(rows)
  rows.inject('') {|html, row| html += li(row) ; html}
end

# write comments to disk for this URI
def save_comments(uri)
  rows = DB.exec_params("select name, created_at, comment
    from comments where uri = $1 order by id", [uri]).to_a
  File.open(BASEDIR + uri, 'w') do |f|
    f.puts ol(rows)
  end
end

# first write them all
DB.exec("select distinct(uri) from comments").each do |r|
  save_comments(r['uri'])
end

# listen for changes. re-write when changed
DB.exec('listen comments_changed')
while true do
  DB.wait_for_notify do |event, pid, uri|
    save_comments(uri)
  end
end
