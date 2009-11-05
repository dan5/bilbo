# -*- encoding: UTF-8 -*-
require 'date'

class Entry
  def date
    Date.parse(label.to_s[/\A\d{8}/])
  rescue TypeError
    update_at
  end

  def update_at
    Dir.chdir(@@entries_dir) { File.mtime(filename) }
  end
end

add_plugin_hook(:before_entry) {|entry|
  %Q!<div class="date">#{ entry.date }</div>!
}
