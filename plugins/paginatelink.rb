# -*- encoding: UTF-8 -*-
def paginate_link(entries)
  page  = params[:page].to_i
  pre_entries = Entry.find('20', :page => page + 1, :limit => limit)
  html = []
  if pre_entries.size > 0
    html << %Q!<span class="paginate">#{ link_to "&lt;前の#{pre_entries.size}件", :controller => "page/#{page + 1}" }</span>!
  end
  if page > 0
    html << %Q!<span class="paginate">#{ link_to "次の#{limit}件&gt;", :controller => "page/#{page - 1}" }</span>!
  end
  html.join(' | ')
end

def limit
  limit = config[:limit] || 5
end

def list(date = '20')
  @entries = Entry.find(date, :page => params[:page] || 0, :limit => limit)
  erb :list
end

before do
  add_plugin_hook(:before_entries) {
    paginate_link(@entries)
  }

  add_plugin_hook(:after_entries) {
    paginate_link(@entries)
  }
end

get '/page/:page' do
  list
  erb :list
end
