# -*- encoding: UTF-8 -*-
if $0 == __FILE__
  require 'rubygems'
  require 'sinatra'
end

def links_2009
  require 'open-uri'
  (open('http://atnd.org/events/2351').read.scan(/【\d+日目】(<a href="[^">]+">[^>]+<\/a>)/) + [nil] * 25)[0, 25]
rescue
  [Rack::Utils.escape($!)]
end

def set_params(year)
  @year = year
  @links = links_2009
  @css = 'http://dgames.jp/bilbo/stylesheets/adventcalendar/adventcalendar.css' # todo:
end

# 記事に埋め込む場合
def adventcalendar(year)
  set_params year
  Haml::Engine.new(AdventCalendarTemplate).render(binding)
end

# アクションとして実行する場合
get '/adventcalendar/:year' do
  set_params params[:year]
  haml AdventCalendarTemplate
end

AdventCalendarTemplate = %q!
.adventcalendar
  %link(rel='stylesheet' type='text/css' href=@css)
  %div
    %h2
      Ruby Advent Calendar jp: 
      = @year
    %ul
      - @links.each_with_index do |link, i|
        - style = link ? 'opened' : 'closed'
        %li(class=style)
          %span(class='day')
            = i + 1
          = link
!
