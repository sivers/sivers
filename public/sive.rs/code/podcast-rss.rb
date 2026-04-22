#!/usr/bin/env ruby
require 'date'
require 'rss'
require 'time'
require 'xml'

ROOT = File.expand_path('../..', __FILE__) + '/'

def parse(fn)
  res = meta(fn)
  res[:pubdate] = File.basename(fn)  # file name is date
  res[:subtitle] = "transcript at sive.rs/#{res[:uri]}" unless res[:subtitle]
  res
end

files = Dir[ROOT + 'content/podcast/*'].sort.reverse
podcast = files.map {|fn| parse(fn)}

doc = XML::Document.new()
doc.root = XML::Node.new('rss')
rss = doc.root
rss['version'] = '2.0'
rss['xmlns:itunes'] = 'http://www.itunes.com/dtds/podcast-1.0.dtd'
rss['xmlns:atom'] = 'http://www.w3.org/2005/Atom'
rss['xmlns:content'] = 'http://purl.org/rss/1.0/modules/content/'
rss['xmlns:googleplay'] = 'https://www.google.com/schemas/play-podcasts/1.0/'
rss << channel = XML::Node.new('channel')
channel << title = XML::Node.new('title')
title << 'Derek Sivers'
channel << description = XML::Node.new('description')
description << 'sive.rs'
channel << managingEditor = XML::Node.new('managingEditor')
managingEditor << 'derek@sivers.org'
channel << copyright = XML::Node.new('copyright')
copyright << '© 2020 Derek Sivers'
channel << generator = XML::Node.new('generator')
generator << 'Derek Sivers'
channel << atomlink = XML::Node.new('atom:link')
atomlink['href'] = 'https://sive.rs/podcast.rss'
atomlink['rel'] = 'self'
atomlink['type'] = 'application/rss+xml'
channel << link = XML::Node.new('link')
link << 'https://sive.rs/'
channel << itunesnewfeed = XML::Node.new('itunes:new-feed-url')
itunesnewfeed << 'https://sive.rs/podcast.rss'
channel << itunesowner = XML::Node.new('itunes:owner')
itunesowner << itunesemail = XML::Node.new('itunes:email')
itunesemail << 'apple@q7r7.com'
itunesowner << itunesname = XML::Node.new('itunes:name')
itunesname << 'Derek Sivers'
channel << itunesauthor = XML::Node.new('itunes:author')
itunesauthor << 'Derek Sivers'
channel << itunessummary = XML::Node.new('itunes:summary')
itunessummary << 'Derek Sivers posts from sive.rs'
channel << itunessubtitle = XML::Node.new('itunes:subtitle')
itunessubtitle << 'Derek Sivers posts from sive.rs'
channel << language = XML::Node.new('language')
language << 'en'
channel << itunesexplicit = XML::Node.new('itunes:explicit')
itunesexplicit << 'no'
channel << cat1 = XML::Node.new('itunes:category')
cat1['text'] = 'Education'
cat1 << subcat1 = XML::Node.new('itunes:category')
subcat1['text'] = 'Self-Improvement'
channel << cat2 = XML::Node.new('itunes:category')
cat2['text'] = 'Society & Culture'
cat2 << subcat2 = XML::Node.new('itunes:category')
subcat2['text'] = 'Philosophy'
channel << cat3 = XML::Node.new('itunes:category')
cat3['text'] = 'Arts'
cat3 << subcat3 = XML::Node.new('itunes:category')
subcat3['text'] = 'Books'
channel << ituneskeywords = XML::Node.new('itunes:keywords')
ituneskeywords << 'Derek Sivers,sivers,sivers.org,sive.rs'
channel << itunestype = XML::Node.new('itunes:type')
itunestype << 'episodic'
channel << itunesimage = XML::Node.new('itunes:image')
itunesimage['href'] = 'https://sive.rs/images/DerekSivers-20141209a-1400.jpg'
channel << image = XML::Node.new('image')
image << image_url = XML::Node.new('url')
image_url << 'https://sive.rs/images/DerekSivers-20141209a-1400.jpg'
image << image_link = XML::Node.new('link')
image_link << 'https://sive.rs/'
image << image_title = XML::Node.new('title')
image_title << 'Derek Sivers'

podcast.each do |p|
  channel << item = XML::Node.new('item')
  item << item_link = XML::Node.new('link')
  item_link << "https://sive.rs/#{p[:uri]}"
  item << title = XML::Node.new('title')
  title << p[:title]
  item << itunestitle = XML::Node.new('itunes:title')
  itunestitle << p[:title]
  item << itunessubtitle = XML::Node.new('itunes:subtitle')
  itunessubtitle << p[:subtitle]
  item << itunesauthor = XML::Node.new('itunes:author')
  itunesauthor << 'Derek Sivers'
  item << description = XML::Node.new('description')
  description << XML::Node.new_cdata(p[:description])
  item << summary = XML::Node.new('itunes:summary')
  summary << XML::Node.new_cdata(p[:description])
  item << contente = XML::Node.new('content:encoded')
  contente << XML::Node.new_cdata(p[:description])
  item << season = XML::Node.new('itunes:season')
  season << p[:season]
  item << guid = XML::Node.new('guid')
  guid << "https://sive.rs/#{p[:uri]}"
  item << pubDate = XML::Node.new('pubDate')
  pubDate << Date.parse(p[:pubdate]).strftime('%a, %d %b %Y %H:%M:%S %z')
  item << itunesepisodeType = XML::Node.new('itunes:episodeType')
  itunesepisodeType << 'full'
  item << itunesexplicit = XML::Node.new('itunes:explicit')
  itunesexplicit << 'no'
  item << itunesimage = XML::Node.new('itunes:image')
  itunesimage['href'] = 'https://sive.rs/images/DerekSivers-20141209a-1400.jpg'
  item << itunesduration = XML::Node.new('itunes:duration')
  itunesduration << p[:duration]
  item << enclosure = XML::Node.new('enclosure')
  enclosure['url'] = "https://m.sive.rs/#{p[:audio]}"
  enclosure['type'] = 'audio/mpeg'
  enclosure['length'] = p[:length].to_s
end

doc.save(WEB_DIR + 'podcast.rss', indent: true, encoding: XML::Encoding::UTF_8)
