require 'plugins/helper.rb'

def permalink(c, name, label)
  c.link_to name, "permalink/#{label}"
end

add_plugin_hook(:after_entry) {|entry, c|
  %Q!<span class="permalink">#{permalink(c, 'permalink', entry.label)}</span>!
}

get '/permalink/:date' do
  @entry = Entry.find(params[:date], :limit => 1, :complete_label => true).first
  @title = "#{@entry.title.gsub(/<.*?>/, '')} - #{config[:title]}"
  haml :entry
end
