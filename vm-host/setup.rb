#!/usr/bin/env ruby

def generate(dst, key)
  vm_num = 16
  if ['serv0', 'serv1', 'serv2', 'serv3', 'serv4', 'serv5'].include?(key) then
    vm_num = 16 # 0-15
  elsif ['serv6'].include?(key) then
    vm_num = 11 # 0-10
  end
  vm_num.times{|i|
    vm = format("vs%s%02d", key[-1], i)
    dst.puts("VBoxManage startvm #{vm} --type headless")
  }
end

key=`hostname -s`.strip

puts("generate startvm.sh")
open("startvm.sh", "w"){|f| generate(f, key) }
system("chmod 755 startvm.sh")

puts("setup crontab")
system("crontab crontab.#{key}")
system("crontab -l")

puts("Don't forget to add `/root/acri-olb/vm-host/startvm.sh` in /etc/rc.local")
