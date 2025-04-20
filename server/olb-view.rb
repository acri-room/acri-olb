#!/usr/bin/env ruby

require 'cgi'
require 'json'

QUERY_SCRIPT = '/usr/local/acri/query_all.sh'
QUERY_RESULT = __dir__ + "/query_all_result.dat"
LOCAL_LOCK   = __dir__ + "/local.lock"

def load_data(y, m, d, host, part)
  str = ""
  
  system("(cd #{__dir__}; #{QUERY_SCRIPT} #{y}-#{m}-#{d})")
  open(QUERY_RESULT){|f|
    str = f.read()
  }

  table = {}
  contents = {}
  lines = str.split("\n")
  lines.each{|line|
    server,slot,user = line.split("\t")
    h = table[server]
    h = {} if h == nil
    h[slot] = user
    table[server] = h
  }
  if part == 'yes'
    table.each{|k, v| contents[k] = v if k.index(host) == 0 }
  else
    contents = table[host]
    contents = {} if contents == nil or contents == ""
  end
  return contents
end

def get_param_value(cgi, key)
  v = nil
  if cgi.params[key] != nil and cgi.params[key][0] != nil then
    v = cgi.params[key][0]
  end
  return v
end

def valid_date?(year, month, date)
  return false if year < 2000
  return false if month < 1 or month > 12
  return false if date < 1 or date > 31
  return true
end

def get_date(cgi)
  year = get_param_value(cgi, 'year').to_i
  month = get_param_value(cgi, 'month').to_i
  date = get_param_value(cgi, 'date').to_i
  if valid_date?(year, month, date) then
    return format("%04d-%02d-%02d", year, month, date).split("-")
  else
    return nil
  end
end

################################################################################
# main
################################################################################

print "Content-type: application/json\n\n"

cgi = CGI.new
date = get_date(cgi)
host = get_param_value(cgi, 'host')
part = get_param_value(cgi, 'partial')
if date == nil or host == nil then
  puts("{}")
else
  open(LOCAL_LOCK, 'w'){|local_lock|
    local_lock.flock(File::LOCK_EX)
    contents = load_data(date[0], date[1], date[2], host, part)
    puts(JSON.generate(contents))
    local_lock.flock(File::LOCK_UN)
  }
end


