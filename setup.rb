#!/usr/bin/env ruby
require 'rbconfig'
require 'fileutils'
require 'pathname'

def foo(fname)
  if File.exist?(fname)
    print "\texists  ", Dir.pwd, '/'
    puts fname
  else
    print "\tcreate  ", Dir.pwd, '/'
    puts fname
    yield(fname)
  end
end

def boot_script(f, run_flag)
  f.puts "#!#{Config::CONFIG['bindir']}/ruby"
  f.puts "$LOAD_PATH.unshift '#{Bilbo_root}/lib'"
  f.puts "$LOAD_PATH.unshift '#{Bilbo_root}'"
  f.puts "require 'start.rb'"
  f.puts "set :run => #{run_flag}, :environment => config[:environment] || :development"
end

def cgi_root
  ARGV.first or 'cgi'
end

Bilbo_root = (Pathname.new(__FILE__).expand_path).dirname
foo(cgi_root) {|dir| Dir.mkdir(cgi_root) }

Dir.chdir(cgi_root) {
  foo('index.cgi') {|fname|
    File.open(fname, 'w') {|f|
      boot_script f, false
      f.puts 'Rack::Handler::CGI.run Sinatra::Application'
    }
    FileUtils.chmod(0755, 'index.cgi')
  }
  foo('server') {|fname|
    File.open(fname, 'w') {|f|
      boot_script f, true
    }
    FileUtils.chmod(0755, 'server')
  }
  foo('bilborc') {|fname|
    rc = File.read(Bilbo_root + 'bilborc.default')
    rc.gsub!('__BILBO_ROOT__', Bilbo_root)
    File.open(fname, 'w') {|f| f.write(rc) }
  }
  foo('.htaccess') {|fname| FileUtils.cp(Bilbo_root + 'dot.htaccess', fname) }
=begin
  foo('favicon.ico') {|fname| FileUtils.cp(Bilbo_root + 'misc/favicon.ico', fname) }
  foo('stylesheets') {|dir| FileUtils.symlink(Bilbo_root + dir, dir) }
  foo('config') {|dir| Dir.mkdir dir }
  foo('config/flavour.html.erb') {|fname| FileUtils.cp(Bilbo_root + fname, fname) }
  foo('config/plugins') {|dir| Dir.mkdir dir }

  %w(flavour
     showdate
     archives
     bilborss
     namedpage
     category
     permalink
     comment
     calender 
     paginatelink
  ).each_with_index {|e, i|
    foo("config/plugins/%02d0_#{e}.rb" % (i)) {|src|
      FileUtils.symlink(Bilbo_root + "plugins/#{e}.rb", src)
    }
  }
=end
}
