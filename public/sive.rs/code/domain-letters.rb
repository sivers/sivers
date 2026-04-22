#!/usr/bin/env ruby
require 'sqlite3'
db = SQLite3::Database.new('domains.db')
query = db.prepare('select domain from domains where domain = ?')
('a'..'z').each do |a|
  ('0'..'9').each do |b|
    ('a'..'z').each do |c|
      ('0'..'9').each do |d|
        combo = a + b + c + d
        rows = query.execute(combo)
        puts combo unless rows.next
      end
    end
  end
end
