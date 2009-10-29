# -*- encoding: UTF-8 -*-
BILBO_VERSION = '0.1.1'

# Helper Part
def link_to(name, options = {})
  controller = options.delete(:controller)
  label = '#' + label if label = options.delete(:label)
  params = options.keys.map {|e| "#{e}=#{options[e]}"}.join('&').sub(/action=/, '')
  %Q!<a href="#{root_path}/#{controller}#{options.empty? ? '' : '?'}#{params}#{label}">#{name}</a>!
end

# Plugin Part
def load_plugins(dir)
  Dir.glob("#{dir}/*.rb").sort.each {|e| load e }
end

$hook_procs ||= {}
def add_plugin_hook(key, priority = 128, &block) # todo: priority
  $hook_procs[key] ||= []
  $hook_procs[key] << block
end

def render_plugin_hook(key)
  ($hook_procs[key] or []).map(&:call).join("\n")
end

# Model Part
require 'pathname'

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
    (@@compilers.assoc(filename.extname) || @@compilers.last)[1].call(self) rescue h($!)
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

if __FILE__ == $0
  load './bilborc'
  setup_environment
  load_plugins config[:dir][:plugins]

  @entries = Entry.find('20')
  require 'pp'
  pp @entries.map(&:to_html)
end
