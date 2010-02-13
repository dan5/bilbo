# -*- encoding: UTF-8 -*-
def paginate_link(c, entries)
  page  = c.params[:page].to_i
  limit = config[:limit] || 5
  pre_entries = Entry.find('20', :page => page + 1)
  action = c.session[:action] || '/page'
  html = []
  base = "#{_root_path}#{action}"
  if pre_entries.size > 0
    html << %Q!<span class="paginate">#{ c.link_to "&lt;前の#{pre_entries.size}件", "#{base}/#{page + 1}" }</span>!
  end
  if page > 0
    url = page == 1 ? base : "#{base}/#{page - 1}"
    html << %Q!<span class="paginate">#{ c.link_to "次の#{limit}件&gt;", url }</span>!
  end
  html.join(' | ')
end

add_plugin_hook(:before_entries) {|c, entries|
  paginate_link(c, entries)
}

add_plugin_hook(:after_entries) {|c, entries|
  paginate_link(c, entries)
}

get '/page/:page' do
  @entries = Entry.find('20', :page => params[:page].to_i)
  haml :list
end
