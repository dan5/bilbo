require 'plugins/helper.rb'

add_plugin_hook(:after_entry) {|entry|
  %Q!<span class="permalink">#{ link_to 'permalink', :controller => "permalink/#{entry.label}" }</span>!
}

get '/permalink/:date' do
  @entry = Entry.find(params[:date], :limit => 1, :complete_label => true).first
  @title = "#{@entry.title.gsub(/<.*?>/, '')} - #{config[:title]}"
  haml :entry
end
