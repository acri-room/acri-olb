#!/usr/bin/env ruby
# public key checker / 2024-12-12 Naoki F., AIT

require 'cgi'
require 'json'

STATUS_STRING = {
  200 => "200 OK",
  400 => "400 Bad Request",
  405 => "405 Method Not Allowed"
}

ACRI_SQL_ROOT = '/tools/acri-sql/'
QUERY_SCRIPT  = ACRI_SQL_ROOT + '/query_updated_keys.sh'
UPDATE_SCRIPT = ACRI_SQL_ROOT + '/update_set_time.sh'

# GET request: obtain recently updated keys
def obtain_keys()
  key_list = `#{QUERY_SCRIPT}`
  results = []
  key_list.split("\n").each do |line|
    nicename, keys, updated = line.split("\t")
    next if ! updated || updated == ''
    valid_keys = []
    keys.split('\\').each do |key| # two backslashes, not one
      check = key.split(' ')
      valid = ((check[0] == 'ssh-ed25519' && check[1].start_with?('AAAAC3NzaC1lZDI1NTE5AAAAI')) ||
               (check[0] == 'ssh-rsa'     && check[1].start_with?('AAAAB3NzaC1yc2E')))
      valid_keys << key if valid
    end
    results << {'nicename' => nicename, 'keys' => valid_keys, 'updated' => updated}
  end
  return [200, JSON.generate(results), true]
end

# POST request: write the time when the keys were set
def update_time(req_body)
  begin
    injson = JSON.parse(req_body)
  rescue JSON::ParserError
    return [400, 'Failed to parse input', false]
  end
  injson.each do |n, d|
    system("#{UPDATE_SCRIPT} #{n} '#{d}'")
  end
  return [200, 'OK', false]
end

def server_main(cgi, req_body)
  if cgi.request_method == "GET"
    return obtain_keys()
  elsif cgi.request_method == "POST"
    return update_time(req_body)
  else
    return [405, 'Unknown method', false]
  end
end

### calling main routine ###
req_body = (ENV['REQUEST_METHOD'] == "POST") ? $stdin.read : ""
ENV['CONTENT_LENGTH'] = "0"
cgi = CGI.new
status_code, message, is_json = server_main(cgi, req_body)
mime_type = (is_json) ? "application/json" : "text/plain"
cgi.out({"status" => STATUS_STRING[status_code], "type" => mime_type}){ message }