#!/usr/bin/env ruby
domain = ''
File.open('com.txt', 'r') do |infile|
  File.open('domains.txt', 'w') do |outfile|
    while line = infile.gets
      temp = line[0...(line.index('.com'))]
      next if temp == domain
      domain = temp
      outfile.puts domain
    end
  end
end
