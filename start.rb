require 'rubygems' # for 1.8
require 'sinatra'

def setup
  load './bilborc'
  setup_environment
  load_plugins config[:dir][:plugins]
end

configure do
  setup
end

get '/:date' do |date|
  @entries = Entry.find(date)
  haml :list
end

get '*' do
  @entries = Entry.find('20')
  haml :list
end
