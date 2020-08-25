#!/usr/bin/env ruby

require 'cgi'
require 'json'

load 'config.rb'
load 'util.rb'

QUERY_SCRIPT = '/usr/local/acri/query_all.sh'
WORKDIR = "/root/acri-olb/server"
QUERY_RESULT = WORKDIR+"/query_all_result.dat"

def load_data(y, m, d, host)
  str = ""

  #if File.exist?(QUERY_RESULT) == false
  #  system("(cd #{WORKDIR}; #{QUERY_SCRIPT} #{y}-#{m}-#{d})")
  #else
  #  t0 = File.mtime(QUERY_RESULT)
  #  t1 = Time.now
  #  if t1 - t0 > 60
  #    system("(cd #{WORKDIR}; #{QUERY_SCRIPT} #{y}-#{m}-#{d})")
  # end
  #end
  system("(cd #{WORKDIR}; #{QUERY_SCRIPT} #{y}-#{m}-#{d})")
  open(QUERY_RESULT){|f|
    str = f.read()
  }

  table = {}
  lines = str.split("\n")
  lines.each{|line|
    server,slot,user = line.split("\t")
    h = table[server]
    h = {} if h == nil
    h[slot] = user
    table[server] = h
  }
  contents = table[host]
  contents = {} if contents == nil or contents == ""
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
if date == nil or host == nil then
  puts("{}")
else
  open(LOCAL_LOCK, 'w'){|local_lock|
    local_lock.flock(File::LOCK_EX)
    #contents = load_datafile(date[0], date[1], date[2], host)
    contents = load_data(date[0], date[1], date[2], host)
    puts(JSON.generate(contents))
    local_lock.flock(File::LOCK_UN)
  }
end


