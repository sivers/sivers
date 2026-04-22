#!/usr/bin/env ruby
require 'sqlite3'
words = File.readlines('/usr/share/dict/words').map(&:strip)
words.select! {|w| w.size <= 4}
db = SQLite3::Database.new('domains.db')
query = db.prepare('select domain from domains where domain = ?')
words.each do |word1|
  words.each do |word2|
    combo = (word1 + word2).downcase
    rows = query.execute(combo)
    puts combo unless rows.next
  end
end
