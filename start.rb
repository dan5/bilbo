require 'rubygems'
require 'sinatra'

configure do
  load './bilborc'
  setup_environment
  load_plugins config[:dir][:plugins]
end

get '/:date' do |date|
  @entries = Entry.find(date)
  haml :list
end

get '*' do
  @entries = Entry.find('20')
  haml :list
end
