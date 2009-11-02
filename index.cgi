#!/home/dan/local/ruby/bin/ruby
require 'start.rb'
set :run => false#, :environment => :production
Rack::Handler::CGI.run Sinatra::Application
