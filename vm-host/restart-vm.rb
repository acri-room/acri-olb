#!/usr/bin/env ruby

SERVER = '172.16.2.5:20080'

VM = ['vs001', 'vs002', 'vs003', 'vs004', 'vs005', 'vs006', 'vs007', 'vs008', 'vs009', 'vs010', 'vs011', 'vs012', 'vs013', 'vs014', 'vs015']
require 'net/http'
require 'uri'
require 'json'

TIMESPAN = 3
BASEDIR = "./"

def begin_time(hour)
  h = (hour / TIMESPAN) * TIMESPAN
  return format("%02d:%02d:%02d", h, 0, 0)
end

def check_reservation(host, t)
  url = "http://#{SERVER}/olb-view.cgi"
  url += "?acri=acri"
  url += "&year=#{t.year}"
  url += "&month=#{t.month}"
  url += "&date=#{t.day}"
  url += "&host=#{host}"
  
  res = Net::HTTP.get(URI.parse(url))
  contents = JSON.parse(res.strip)
  user = contents[begin_time(t.hour)]
  puts("check:#{host}, #{begin_time(t.hour)} => #{user}")
  if(user == nil) then
    puts("no valid user in this timeslot")
  else
    puts("valid user is #{user}")
  end
  return user
end

def check_user_diff(host)
  t = Time.now
  cur = check_reservation(host, t)
  prev = check_reservation(host, t-(TIMESPAN*60*60)) # before 1H
  return (cur == prev)
end

###########################################################
# main
###########################################################
restarts = []
VM.each{|host|
  flag = check_user_diff(host)
  p flag
  restarts << host unless flag
}
p restarts
cmd = "#{__dir__}/stopvm.sh #{restarts.join(' ')}"
puts(cmd)
system(cmd)
restarts.each{|host|
  cmd = "VBoxManage startvm #{host} --type headless"
  puts(cmd)
  system(cmd)
}
