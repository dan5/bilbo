# -*- encoding: UTF-8 -*-
def paginate_link(c, entries)
  page  = c.params[:page].to_i
  limit = c.params[:limit].to_i
  limit = config[:limit] || 5 if limit <= 0
  options = {}
  options[:page]  = page + 1
  options[:limit] = limit
  pre_entries = Entry.find(options[:date] || '20', options)
  options[:date]  = c.params[:date] if c.params[:date]
  html = []
  if pre_entries.size > 0
    html << %Q!<span class="paginate">#{ link_to "&lt;前の#{pre_entries.size}件", options }</span>!
  end
  if page > 0
    options[:page] = page - 1
    html << %Q!<span class="paginate">#{ link_to "次の#{limit}件&gt;", options }</span>!
  end
  html.join(' | ')
end

add_plugin_hook(:before_entries) {|c, entries|
  paginate_link(c, entries)
}

add_plugin_hook(:after_entries) {|c, entries|
  paginate_link(c, entries)
}
