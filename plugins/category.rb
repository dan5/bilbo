class Entry
  def categories
    all_categories.select {|e| ch_datadir { File.exist?("category/#{Rack::Utils.escape(e)}/#{filename}") } }
  end

  alias :_orig_to_html :to_html # trap
  def to_html
    _orig_to_html.gsub(/<h2>(<[^>]*>\s*)*\[.+?<\/h2>/m) { $&.gsub(/\[.+?\]/, '') }
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

def _all_categories
  ch_datadir {
    File.exist?("category") ? Dir.chdir("category") { Dir.glob('*') }.map {|e| Rack::Utils.unescape(e) } : []
  }
end

def all_categories
  config[:categories] or _all_categories
end

def entries_size(category)
  ch_datadir { Dir.glob("category/#{Rack::Utils.escape(category)}/*").size } 
end

def link_to_category(c, category)
  s = "#{category}(#{entries_size(category)})"
  c.link_to(s, "#{_root_path}/category/#{Rack::Utils.escape(category)}")
end

add_plugin_hook(:before_content) {|c, |
  a = all_categories.map {|e| link_to_category(c, e) }.join(' ')
  (c.params[:category] || c.session[:render_category_list]) ? %Q!<div class="categories"><p>#{ a }</p></div>! : ''
}

add_plugin_hook(:after_entry) {|entry, c|
  a = entry.categories
  a.map! {|e| e.force_encoding 'UTF-8' } if defined? Encoding
  a.empty? ? '' : %Q!<div class="category">category: #{ a.map {|e| link_to_category(c, e) }.join(' ') }</div>!
}

def render_category(page = 0)
  session[:action] = "/category/#{params[:category]}"
  add_plugin_hook(:before_header) {
    "<head><title>#{config[:title]}: Categories: #{params[:category]}</title></head>"
  }
  dir = config[:dir][:entries]
  dir += '/category/' + Rack::Utils.escape(params[:category]) if params[:category]
  chdir(dir) {
    @entries = Entry.find('20', :page => page)
    haml :list
  }
end

get '/category/:category/:page' do
  render_category(params[:page].to_i)
end

get '/category/:category' do
  render_category
end

get '/category' do
  haml all_categories.map {|e| link_to_category(self, e) }.join(' ')
end

__END__
Plugin.add_hook(:before_archives) {
<<HTML
  <h2>Categories</h2>
  <p>#{ link_to_categories(' ') }</p>
HTML
}
