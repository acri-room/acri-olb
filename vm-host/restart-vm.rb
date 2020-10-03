#!/usr/bin/env ruby

SERVER = '172.16.2.5:20080'

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
  t = t + 5 * 60 # 5 min. future
  cur = check_reservation(host, t)
  prev = check_reservation(host, t-(TIMESPAN*60*60)) # before 1H
  return (cur == prev)
end

###########################################################
# main
###########################################################
if ARGV.size != 1 then
  puts("arguments error")
  exit(0)
end
VM = ARGV

restarts = []

VM.each{|host|
  flag = check_user_diff(host)
  p flag
  restarts << host unless flag
}
p restarts

restarts.each{|host|
    system("VBoxManage controlvm #{host} acpipowerbutton")
}

WAIT_LIMIT=5
restarts.each{|host|
  str = `VBoxManage list runningvms | grep #{host}`
  n = 0
  while(str.strip.size > 0)
    system("VBoxManage controlvm #{host} poweroff") if(n == WAIT_LIMIT)
    n += 1 if n < (WAIT_LIMIT + 1)
    puts("wait for stop #{host} (#{n})")
    sleep 5
    str = `VBoxManage list runningvms | grep #{host}`
  end
}

restarts.each{|host|
  cmd = "VBoxManage startvm #{host} --type headless"
  puts(cmd)
  system(cmd)
}
