# -*- encoding: UTF-8 -*-
class Comment
  attr_reader :filename

  def initialize(filename, data = nil)
    filename[/\A\d{8}/] or raise(filename)
    filename[/[^\d\w_\.]/] and raise(filename)
    @filename = Pathname.new(filename)
    @data = data
  end

  def data
    @data ||= self.class.chdir { @filename.read }
  end

  def label
    @filename.to_s[/\A\d+_(.+)_c/]; $1
  end

  def body
    data.sub(/\A.*\n/, '')
  end

  def name
    data[/\A.*$/]
  end

  def time_str
    @filename.to_s[/\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d\d)/]
    "#{$1}/#{$2}/#{$3} #{$4}:#{$5}:#{$6}"
  end

  def to_html(c, idx = 1)
    num = 'c%02d' % idx
    html = <<HTML
      <span class="name">#{Rack::Utils.unescape name}</span>
      <span class="time"><a name="#{num}">#{permalink(c, Rack::Utils.unescape(time_str), label, '#' + num)}</a></span>
      <p>#{Rack::Utils.unescape(body).gsub(/\n/, '<br />')}</p>
HTML
  end

  def self.find(pattern, options = {})
    pattern = pattern.to_s.gsub(/[^\d\w_*]/, '') # DON'T DELETE!!!
    # bug:
    limit = options[:limit] || 1000
    chdir { Dir.glob("*_#{pattern}_c*") }.sort.reverse[0, limit].map {|e| self.new(e) }.reverse
  rescue Errno::ENOENT
    []
  end

  def self.chdir(subdir = '')
    dir = Pathname.new(config[:dir][:entries]) + 'comments' + subdir
    dir.mkdir unless dir.exist?
    Dir.chdir(dir) { yield }
  end
end

def comment_viewer_html(c, entry)
  comments = Comment.find(entry.label)
  return '' if comments.size == 0
  ct = 0
  html = comments.map {|e| e.to_html(c, ct += 1) }.join("\n")
  <<-HTML
    <div class="comments">
      <h4><a name="c">Comments</a></h4>
      #{html}
    </div>
  HTML
end

add_plugin_hook(:after_entry) {|entry, c|
  if c.env['PATH_INFO'] =~ /^\/permalink\//
    comment_viewer_html(c, entry)
  end
}
