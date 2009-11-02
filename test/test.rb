load './bilborc'
setup_environment
load_plugins config[:dir][:plugins]

@entries = Entry.find('20')
require 'pp'
pp @entries.map(&:to_html)
puts :hello_test
