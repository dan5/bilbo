# -*- encoding: UTF-8 -*-
require 'date'

class Entry
  def date
    str = Date.parse(label.to_s[/\A\d{8}/])
    defined?(permalink) ? permalink($sinatra_context, str, label) : str
  rescue TypeError
    update_at
  end

  def update_at
    Dir.chdir(@@entries_dir) { File.mtime(filename) }
  end
end

before do
  $sinatra_context = self
end

add_plugin_hook(:before_entry) {|entry|
  %Q!<div class="date">#{ entry.date }</div>!
}
