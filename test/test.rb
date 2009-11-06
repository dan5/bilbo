def get(*a); end
def use_in_file_templates!; end

load 'test/boot/bilborc'
setup_environment
load_plugins config[:dir][:plugins]

@entries = Entry.find('20')
puts @entries.map(&:to_html)
