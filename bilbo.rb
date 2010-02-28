# -*- encoding: UTF-8 -*-
require 'pathname'
BILBO_VERSION = '0.2.0'

# Helper Part
def _root_path # todo: name
  ENV['SCRIPT_NAME'] ? File.dirname(ENV['SCRIPT_NAME']) : ''
end

# Plugin Part
def load_plugins(dir)
  $hook_procs = {}
  Dir.glob("#{dir}/*.rb").sort.each {|e| load e }
end

def add_plugin_hook(key, priority = 128, &block) # todo: priority
  $hook_procs[key] ||= []
  $hook_procs[key] << block
end

def render_plugin_hook(key, *args)
  ($hook_procs[key] or []).map {|e| e.call(*args) }.join("\n")
end

# Model Part
class Entry
  attr_reader :filename, :header, :body
  def initialize(filename)
    @filename = Pathname.new(filename)
    @header, @body = Dir.chdir(@@entries_dir) { @filename.read }.split(/^__$/, 2)
    @header, @body = nil, @header unless @body
  end

  def label
    filename.basename('.*')
  end

  def to_html
    (@@compilers.assoc(filename.extname) || @@compilers.last)[1].call(self) rescue Rack::Utils.escape_html($!)
  end

  def self.find(pattern, options = {})
    pattern.gsub!(/[^\d\w_]/, '') # DON'T DELETE!!!
    pattern += '\.' if options[:complete_label]
    limit = options[:limit] || 5
    files = Dir.chdir(@@entries_dir) { Dir.glob("#{pattern}*") }.sort.reverse
    (files[limit * (options[:page] || 0), limit] || []).map {|e| Entry.new(e) }
  end

  @@compilers = [[nil, lambda {|entry| entry.body }]]
  def self.add_compiler(extname = nil, &block)
    @@compilers.unshift [extname, block]
  end

  @@entries_dir = nil
  def self.entries_dir=(dir)
    @@entries_dir = dir
  end
end
