def flavour
  @flavour ||= File.read('config/flavour.haml').split(/^__CONTENT__.*$/)
end

add_plugin_hook(:flavour_header) {|c|
  c.haml(flavour.first, :layout => false)
}
  
add_plugin_hook(:flavour_footer) {|c|
  c.haml(flavour.last, :layout => false)
}
