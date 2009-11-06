# -*- encoding: UTF-8 -*-
load 'plugins/helper.rb'

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
  archives('20')
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
        = link_to entry.date, :controller => entry.label
        = entry.title
