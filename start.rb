require 'rubygems' # for 1.8
require 'sinatra'
require 'sinatra_more/markup_plugin'
Sinatra::Base.register SinatraMore::MarkupPlugin

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
  @entries = Entry.find('20',
                        :limit => (params[:limit] || config[:limit] || 5).to_i,
                        :page => (params[:page] || 0).to_i)
  haml :list
end
