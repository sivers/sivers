#!/usr/bin/env ruby
require 'sqlite3'
db = SQLite3::Database.new('domains.db')
query = db.prepare('select domain from domains where domain = ?')
File.readlines('/usr/share/dict/words').each do |word|
  rows = query.execute(word.downcase.strip)
  puts word unless rows.next
end
