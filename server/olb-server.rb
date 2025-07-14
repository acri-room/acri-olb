#!/usr/bin/env ruby
require 'webrick'

OLBVIEW_ALLOW_LIST = [
  '127.0.0.1',
  '172.16.2.5',
  '172.16.3.',
  '172.16.5.',
  '172.16.6.',
  '172.16.77.']

KEYPROCESS_ALLOW_LIST = [
  '127.0.0.1',
  '172.16.2.2']

def address_allow?(addr, allow_list)
  allow_list.each do |prefix|
    if (prefix[-1] == '.') ? (addr.start_with?(prefix)) : (addr == prefix)
      return true
    end
  end
  return false
end

def olbview_address_allow?(addr)    address_allow?(addr, OLBVIEW_ALLOW_LIST) end
def keyprocess_address_allow?(addr) address_allow?(addr, KEYPROCESS_ALLOW_LIST) end

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
