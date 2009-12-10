class Entry
  def categories
    all_categories.select {|e| ch_datadir { File.exist?("category/#{Rack::Utils.escape(e)}/#{filename}") } }
  end

  alias :_orig_to_html :to_html # trap
  def to_html(b)
    _orig_to_html(b).gsub(/<h2>(<[^>]*>\s*)*\[.+?<\/h2>/m) { $&.gsub(/\[.+?\]/, '') }
  end

  def self.entries_dir
    @@entries_dir
  end
end

def chdir(dir)
  tmp, Entry.entries_dir = Entry.entries_dir, dir
  ret = yield
  Entry.entries_dir = tmp
  ret
end

def ch_datadir
  Dir.chdir(config[:dir][:entries]) { yield }
end

def all_categories
  ch_datadir {
    File.exist?("category") ? Dir.chdir("category") { Dir.glob('*') }.map {|e| Rack::Utils.unescape(e) } : []
  }
end

def entries_size(category)
  ch_datadir { Dir.glob("category/#{Rack::Utils.escape(category)}/*").size } 
end

def link_to_category(category)
  s = "#{category}(#{entries_size(category)})"
  link_to(s, :controller => "category/#{Rack::Utils.escape(category)}")
end

add_plugin_hook(:before_entries) {|c|
  a = all_categories.map {|e| link_to_category(e) }.join(' ')
  c.params[:category] ? %Q!<div class="categories"><p>#{ a }</p></div>! : ''
}

add_plugin_hook(:after_entry) {|entry|
  a = entry.categories
  a.empty? ? '' : %Q!<div class="category">category: #{ a.map {|e| link_to_category(e) }.join(' ') }</div>!
}

get '/category/:category' do
  add_plugin_hook(:before_header) {
    "<head><title>#{config[:title]}: Categories: #{params[:category]}</title></head>"
  }
  dir = config[:dir][:entries]
  dir += '/category/' + Rack::Utils.escape(params[:category]) if params[:category]
  chdir(dir) {
    @entries = Entry.find('20')
    haml :list
  }
end

get '/category' do
  haml all_categories.map {|e| link_to_category(e) }.join(' ')
end

__END__
Plugin.add_hook(:before_archives) {
<<HTML
  <h2>Categories</h2>
  <p>#{ link_to_categories(' ') }</p>
HTML
}
