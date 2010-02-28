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
      name = if config[:categories]
               idx = (config[:categories] or []).map(&:upcase).index(e.first.upcase)
               next unless idx
               config[:categories][idx]
             else 
               e
             end
      dir = rootdir + Rack::Utils.escape(name)
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
  def eval_hiki_plugin(html) html; end

  load ARGV.first # load bilborc
  setup_environment
  categoriz
end
