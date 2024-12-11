#!/usr/bin/env ruby
require 'webrick'

load 'config.rb'

def olbview_address_allow?(addr)
  addr == '127.0.0.1' ||
  addr == '172.16.2.5' ||
  addr.start_with?('172.16.3.') ||
  addr.start_with?('172.16.5.') ||
  addr.start_with?('172.16.6.')
end

def keyprocess_address_allow?(addr)
  addr == '172.16.2.2'
end

srv = WEBrick::HTTPServer.new({ :DocumentRoot => './doc/',
                                :BindAddress => '0.0.0.0',
                                :Port => 20080})
srv.mount_proc('/olb-view.cgi') do |req, res|
  raise WEBrick::HTTPStatus::Forbidden if ! olbview_address_allow?(req.peeraddr[3])
  WEBrick::HTTPServlet::CGIHandler.new(srv, 'olb-view.rb').do_GET(req, res)
end
srv.mount_proc('/keys-process.cgi') do |req, res|
  raise WEBrick::HTTPStatus::Forbidden if ! keyprocess_address_allow?(req.peeraddr[3])
  handler = WEBrick::HTTPServlet::CGIHandler.new(srv, 'keys-process.rb')
  (req.request_method == "GET") ? handler.do_GET(req, res) : handler.do_POST(req, res)
end
trap("INT"){ srv.shutdown }
srv.start
