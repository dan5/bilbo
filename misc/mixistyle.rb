require 'uri'
class MixiStyle
  def self.to_html(text)
    html = text.sub(/\A(.+)\n+/) { "<h2>#{$1}</h2>" }.
           gsub(URI.regexp(%w(http https ftp mailto))) {|m| %[<a href="#{m}">#{m}</a>] }.
           gsub("\n", "<br />\n")
  end
end
