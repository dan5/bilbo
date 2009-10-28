# -*- encoding: UTF-8 -*-

# helper.rb
require 'pathname'
BILBO_VERSION = '0.1.0'
def chdir(key) Dir.chdir(config[:dir][key]) { yield }; end
def load_plugins() Dir.glob("#{config[:dir][:plugins]}/*.rb").sort.each {|e| load e }; end

# model.rb
class Entry
  attr_reader :filename
  def initialize(filename)
    @filename = Pathname.new(filename)
  end

  def label
    filename.basename('.*')
  end

  def body
    @body ||= chdir(:entries) { filename.read }
  end

  def to_html
    @@compilers[filename.extname].call(self) rescue h($!)
  end

  def self.find(pattern, options = {})
    pattern.gsub!(/[^\d\w_]/, '') # DON'T DELETE!!!
    pattern += '\.' if options[:complete_label]
    limit = (options[:limit] || config[:limit] || 3).to_i
    files = chdir(:entries) { Dir.glob("#{pattern}*") }.sort.reverse
    (files[limit * options[:page].to_i, limit] || []).map {|e| Entry.new(e) }
  end

  @@compilers = Hash.new(lambda {|entry| entry.body })
  def self.add_compiler(extname, &block)
    @@compilers[extname] = block
  end
end

if __FILE__ == $0
  load './bilborc'
  setup_environment
  load_plugins

  puts :hello

  @entries = Entry.find('20')
  require 'pp'
  pp @entries.map(&:to_html)
end
