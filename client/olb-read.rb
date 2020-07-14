#!/usr/bin/env ruby

SERVER = '172.16.2.5:20080'

require 'net/http'
require 'uri'
require 'json'

TIMESPAN = 3
BASEDIR = "./"
SSHD_CONFIG_BASE = BASEDIR+"/sshd_config.base"
SSHD_CONFIG_NEW = BASEDIR+"/sshd_config.new"
XRDP_CONFIG_BASE = BASEDIR+"/xrdp.ini.base"
XRDP_CONFIG_NEW = BASEDIR+"/xrdp.ini.new"

def begin_time(hour)
  h = (hour / TIMESPAN) * TIMESPAN
  return format("%02d:%02d:%02d", h, 0, 0)
end

def generate_xrdp_config(user)
  str = ""
  newstr = ""
  open(XRDP_CONFIG_BASE, "r"){ |f| str = f.read() }
  str.split("\n").each{|line|
    if(line == "username=ask") then
      line = "username=#{user}"
    end
    newstr += line + "\n"
  }
  open(XRDP_CONFIG_NEW, "w"){ |f| f.write(newstr) }
end

def generate_sshd_config(user)
  str = ""
  open(SSHD_CONFIG_BASE, "r"){ |f| str = f.read() }
  str += "\n"
  str += "AllowUsers"
  str += " acriuser" # acriuser can alway login the host
  if user != nil then
    str += " " + user
  end
  str += "\n"
  open(SSHD_CONFIG_NEW, "w"){ |f| f.write(str) }
end

###########################################################
# main
###########################################################

t = Time.now
t = t + (5 * 60) # 5 min. future
host = `hostname -s`.strip

url = "http://#{SERVER}/olb-view.cgi"
url += "?acri=acri"
url += "&year=#{t.year}"
url += "&month=#{t.month}"
url += "&date=#{t.day}"
url += "&host=#{host}"

res = Net::HTTP.get(URI.parse(url))
contents = JSON.parse(res.strip)
user = contents[begin_time(t.hour)]
if(user == nil) then
  puts("no valid user in this timeslot")
else
  puts("valid user is #{user}")
end

generate_sshd_config(user)
system("mv #{SSHD_CONFIG_NEW} /etc/ssh/sshd_config")
system("systemctl restart ssh")

user = 'acriuser' if user == nil
generate_xrdp_config(user)
system("mv #{XRDP_CONFIG_NEW} /etc/xrdp/xrdp.ini")
system("systemctl restart xrdp")
