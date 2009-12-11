# -*- encoding: UTF-8 -*-
if $0 == __FILE__
  require 'rubygems'
  require 'sinatra'
end

def links_2009
  require 'open-uri'
  (open('http://atnd.org/events/2351').read.scan(/【\d+日目】(<a href="[^">]+">[^>]+<\/a>)/))[0, 25]
rescue
  [Rack::Utils.escape($!)]
end

def set_params(year)
  @year = year
  @links = links_2009
  @css = 'http://dgames.jp/bilbo/stylesheets/adventcalendar.css' # todo:
end

def adventcalendar(year)
  set_params year
  Haml::Engine.new(AdventCalendarTemplate).render(binding)
end

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
        - day = "day#{i + 1}"
        %li
          %span
            = i + 1
          = link
!
