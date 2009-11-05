require 'rubygems' # for 1.8
require 'sinatra'

def setup
  load './bilborc'
  setup_environment
end

configure do
  setup
end

configure :development do
  @force_loading = true
end

before do
  setup if @force_loading
  load_plugins config[:dir][:plugins], @force_loading
  @css = config[:css] # todo: set this in view
end

get '/:date' do |date|
  @entries = Entry.find(date)
  haml :list
end

get '*' do
  @entries = Entry.find('20')
  haml :list
end
