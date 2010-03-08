require 'plugins/helper.rb'

def permalink(c, name, label, anchor = nil)
  c.link_to name, "#{_root_path}/permalink/#{label}#{anchor}"
end

add_plugin_hook(:after_entry) {|entry, c|
  %Q!<span class="permalink">#{permalink(c, 'permalink', entry.label)}</span>!
}

get '/permalink/:date' do
  @entry = Entry.find(params[:date], :limit => 1, :complete_label => true).first
  @title = "#{@entry.title.gsub(/<.*?>/, '')} - #{config[:title]}"
  haml :entry
end
