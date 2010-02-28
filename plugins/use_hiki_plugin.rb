def eval_hiki_plugin(html)
  html.gsub(/<(div|span) class=\"plugin\">\{\{(.+)\}\}<\/(div|span)>/) { eval($2) }
end
