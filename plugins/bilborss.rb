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

# http://www.machu.jp/diary/20090818.html#p01
def base_url(request)
  default_port = (request.scheme == "http") ? 80 : 443
  port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
  "#{request.scheme}://#{request.host}#{port}"
end

def generate_rss(entries, options = {})
  base_path = request.script_name.sub(/\/?[^\/]*$/, '')
  top = base_url(request) + base_path
  RSS::Maker.make("1.0") do |maker|
    entries.each do |entry|
      item = maker.items.new_item
      item.link            = "#{top}/permalink/#{entry.label}"
      item.description     = entry.rss_description
      item.title           = entry.rss_tile
      item.content_encoded = entry.rss_body
      item.date            = entry.time
    end
    maker.channel.link  = top
    maker.channel.about = options[:about] || "abaout"
    maker.channel.title = options[:title] || config[:title]
    maker.channel.description = options[:description] || config[:description] || 'Please set config[:description] in bilborc'
  end.to_s
end

get '/rss' do
  generate_rss(Entry.find('20', :limit => 20))
end

add_plugin_hook(:header) {|c|
  base_path = c.request.script_name.sub(/\/?[^\/]*$/, '')
  %Q!<link rel="alternate" type="application/rss+xml" title="RSS" href="#{base_path}/rss">!
}
