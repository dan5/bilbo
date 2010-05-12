# -*- encoding: UTF-8 -*-
load 'plugins/helper.rb'

def _permalink(c, name, label)
  if defined? :permalink
    permalink(c, name, label)
  else
    c.link_to name, label
  end
end

def archives(date, options = {})
  @entries = Entry.find(date, :limit => (options[:limit] || 200).to_i,
                              :page => (options[:page] || 0).to_i)
  @title = "#{config[:title]}: archives"
  haml :archives
end

get '/archives/:date' do
  archives(params[:date] || '20')
end

get '/archives' do
  session[:render_category_list] = true
  archives('20', :limit => 2000)
end

use_in_file_templates! 

__END__

@@ archives
.archives
  = render_plugin_hook(:before_archives)
  %div
    %h2 Entries
    %ul
      - @entries.each do |entry|
        %li
          = _permalink self, entry.date, entry.label
          = entry.title
