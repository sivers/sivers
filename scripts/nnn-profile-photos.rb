#!/usr/bin/env ruby
# update now_profiles.photo = true for each local *.webp photo (named with its public_id)

require 'pg'
DB = PG::Connection.new(dbname: 'sivers', user: 'sivers')

public_ids = []
Dir['/var/www/html/nownownow.com/m/*.webp'].each do |f|
  public_ids << File.basename(f, '.webp')
end

DB.exec("update now_profiles set photo = false")
DB.exec("update now_profiles set photo = true where public_id in ('%s')" % public_ids.join("','"))

