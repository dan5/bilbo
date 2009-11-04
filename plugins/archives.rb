# -*- encoding: UTF-8 -*-
load 'plugins/helper.rb'

get '/archives' do
  date = params[:date] || '20'
  @entries = Entry.find(date, :limit => (params[:limit] || 200).to_i,
                              :page => (params[:page] || 0).to_i)
  @title = "#{config[:title]}: archives"
  erb :archives
end

template :archives do
  <<-VIEW
  <div class="archives">
    <%= render_plugin_hook(:before_archives) %>
    <div><h2>Entries</h2>
    <ul>
    <% @entries.each do |entry| %>
      <li><%= link_to entry.date, :controller  => entry.label %> <%= entry.title %></li>
    <% end %>
    </ul>
    </div>
  </div>
  VIEW
end
