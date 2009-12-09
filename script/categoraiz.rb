#!/usr/bin/env ruby
require 'rubygems'
require 'rack'

class Entry
  def category_title
    to_html[/<h2>.*?<\/h2>/i].to_s.gsub(/<[^>]*>/, '')
  end

  def self.entries_dir
    @@entries_dir
  end
end

def categoriz
  rootdir = Pathname.new('category')
  datadir = Entry.entries_dir
  Dir.chdir(datadir) {
    FileUtils.remove_entry_secure(rootdir, true) if rootdir.exist?
    rootdir.mkdir
  }
  @entries = Entry.find('20', :limit => 99999)
  @entries.each do |entry|
    entry.category_title.scan(/\[([^\]]+)\]/).each do |e|
      next if config[:categories] and !config[:categories].index(e.first)
      dir = rootdir + Rack::Utils.escape(e.first)
      Dir.chdir(datadir) {
        dir.mkdir unless dir.exist?
        Dir.chdir(dir) {
          unless entry.filename.exist?
            FileUtils.symlink "../../#{entry.filename}", './'
            puts "      categoriz #{entry.filename} #{dir}"
        end
        }
      }
    end
  end
end

if __FILE__ == $0
  load ARGV.first # load bilborc
  setup_environment
  categoriz
end
