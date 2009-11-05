def flavour
  @flavour ||= File.read('config/flavour.haml').split(/^__CONTENT__.*$/)
end

add_plugin_hook(:flavour_header) {
  haml(flavour.first, :layout => false)
}
  
add_plugin_hook(:flavour_footer) {
  haml(flavour.last, :layout => false)
}
