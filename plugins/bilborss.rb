# -*- encoding: UTF-8 -*-
require 'rss/maker'

class Entry
  def rss_description(n = 128)
    "#{ /^.{0,#{n}}/m.match(to_html.gsub(/(.*<\/h3>)|(<[^>]*>)|(\s+)/mi, '')) }..."
  end

  def rss_tile
     to_html[/<h2>.*<\/h2>/i].to_s.gsub(/<[^>]*>/, '')
  end

  def rss_body
    to_html
  end

  require 'time'
  def time
    Time.parse(date.to_s)
  end
end

def rss_uri_base
  (
    (config[:rss] || {})[:uri] ||
    "http://#{ENV['HTTP_HOST']}#{ENV['REQUEST_URI']}"
  ).sub(/[^\/]+$/, '')
end

def rss_uri
  (config[:rss] || {})[:uri] || "#{rss_uri_base}rss"
end

def rss_filename
  rss_uri.split('/').last
end

def base_url # from Hiki source
  if !ENV['SCRIPT_NAME']
    ''
  elsif ENV['HTTPS'] && /off/i !~ ENV['HTTPS']
    port = (ENV['SERVER_PORT'] == '443') ? '' : ':' + ENV['SERVER_PORT'].to_s
    "https://#{ ENV['SERVER_NAME'] }#{ port }#{File::dirname(ENV['SCRIPT_NAME'])}/".sub(%r|/+$|, '/')
  else
    port = (ENV['SERVER_PORT'] == '80') ? '' : ':' + ENV['SERVER_PORT'].to_s
    "http://#{ ENV['SERVER_NAME'] }#{ port }#{File::dirname(ENV['SCRIPT_NAME'])}/".sub(%r|/+$|, '/')
  end
end

def generate_rss(entries, options = {})
  RSS::Maker.make("1.0") do |maker|
    entries.each do |entry|
      item = maker.items.new_item
      item.link            = "#{rss_uri_base}permalink/#{entry.label}"
      item.description     = entry.rss_description
      item.title           = entry.rss_tile
      item.content_encoded = entry.rss_body
      item.date            = entry.time
    end
    maker.channel.link  = options[:link] || rss_uri_base || base_url
    maker.channel.about = options[:about] || "abaout"
    maker.channel.title = options[:title] || config[:title]
    maker.channel.description = options[:description] || config[:description] || 'Please set config[:description] in bilborc'
  end.to_s
end

get '/rss' do
  generate_rss(Entry.find('20', :limit => 20))
end

add_plugin_hook(:header) {
  %Q!<link rel="alternate" type="application/rss+xml" title="RSS" href="#{rss_filename}">!
}
