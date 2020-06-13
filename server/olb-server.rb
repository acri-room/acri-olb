#!/usr/bin/env ruby
require 'webrick'

load 'config.rb'

srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
                                :BindAddress => '0.0.0.0',
                                :Port => 20080})
srv.mount('/olb-view.cgi', WEBrick::HTTPServlet::CGIHandler, 'olb-view.rb')
trap("INT"){ srv.shutdown }
srv.start
