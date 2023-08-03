#!/usr/bin/env ruby
require 'webrick'

load 'config.rb'

def address_allow?(addr)
  addr == '127.0.0.1' ||
  addr == '172.16.2.5' ||
  addr.start_with?('172.16.3.') ||
  addr.start_with?('172.16.5.') ||
  addr.start_with?('172.16.6.')
end

srv = WEBrick::HTTPServer.new({ :DocumentRoot => './doc/',
                                :BindAddress => '0.0.0.0',
                                :Port => 20080})
srv.mount_proc('/olb-view.cgi') do |req, res|
  raise WEBrick::HTTPStatus::Forbidden if ! address_allow?(req.peeraddr[3])
  WEBrick::HTTPServlet::CGIHandler.new(srv, 'olb-view.rb').do_GET(req, res)
end
trap("INT"){ srv.shutdown }
srv.start
