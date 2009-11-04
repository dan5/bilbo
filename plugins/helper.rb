# -*- encoding: UTF-8 -*-
class Entry
  def title
    to_html[/<h2>(.*?)<\/h2>/m] ? $1 : 'no title'
  end

  def body_without_tag
    to_html.sub(/<h2>(.*?)<\/h2>/, '').gsub(/(<[^>]*>)|(\s+)/m, ' ')
  end

  def head
    /^.{0,64}/m.match(body_without_tag)[0]
  end
end
