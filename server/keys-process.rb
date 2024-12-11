#!/usr/bin/env ruby
# public key checker / 2024-12-11 Naoki F., AIT

require 'cgi'
require 'json'

STATUS_STRING = {
  200 => "200 OK",
  400 => "400 Bad Request",
  405 => "405 Method Not Allowed"
}

QUERY_SCRIPT = '/usr/local/acri/query_updated_keys.sh'

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

def server_main(cgi)
  if cgi.request_method == "GET"
    return obtain_keys()
  elsif cgi.request_method == "POST"
    return [200, "OK", false]
  else
    return [405, 'Unknown method', false]
  end
end

### calling main routine ###
cgi = CGI.new
status_code, message, is_json = server_main(cgi)
mime_type = (is_json) ? "application/json" : "text/plain"
cgi.out({"status" => STATUS_STRING[status_code], "type" => mime_type}){ message }