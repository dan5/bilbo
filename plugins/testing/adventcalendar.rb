# -*- encoding: UTF-8 -*-

def links_2009
  require 'open-uri'
  open('http://atnd.org/events/2351').read.scan(/【\d+日目】(<a href="[^">]+">[^>.]+<\/a>)/) * 5
end

get '/adventcalendar/:year' do
  add_plugin_hook(:before_header) {
    "<head><title>#{config[:title]}: Ruby Advent Calendar jp: #{params[:year]}</title></head>"
  }
  @links = links_2009
  haml :adventcalendar
end

use_in_file_templates!

__END__

@@ adventcalendar
.adventcalendar
  %div
    %h2
      Ruby Advent Calendar jp: 
      = params[:year]
    %ul
    - @links.each_with_index do |link, i|
      - day = "day#{i + 1}"
      %li{:'id' => day}
        %span
          = i + 1
        = link
