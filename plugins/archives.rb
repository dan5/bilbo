# -*- encoding: UTF-8 -*-
load 'plugins/helper.rb'

get '/archives/:date' do
  date = params[:date] || '20'
  @entries = Entry.find(date, :limit => (params[:limit] || 200).to_i,
                              :page => (params[:page] || 0).to_i)
  @title = "#{config[:title]}: archives"
  haml :archives
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
