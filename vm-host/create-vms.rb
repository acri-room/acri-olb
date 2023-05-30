#!/usr/bin/env ruby

require 'json'

DATADIR = "/tools/acri-olb/vm-host/data/"
VMFILE = DATADIR + "created-vms.json"

def main()
  if ARGV.size != 4
    STDERR.puts "usage: ./create-vms.rb HOSTNAME_PREFIX IP_PREFIX SKEL NUM_VM"
    exit 1
  end
  host_prefix = ARGV[0]
  ip_prefix = ARGV[1]
  skel = ARGV[2]
  num_vm = ARGV[3]

  str = `VBoxManage list vms`
  vms = str.strip().split("\n").map{|l| d=l.split(" "); d[0][1..-2]}
  if ! vms.include?(skel)
    puts "VM to be cloned (#{skel}) is not registered. Stop."
    exit 1
  end

  created = []
  0.upto(num_vm.to_i).each do |i|
    vmname = "%s%02d" % [host_prefix, i]
    vmip = "%s.%d/16" % [ip_prefix, i]
    system("VBoxManage clonevm #{skel} --basefolder=/usr/local/vm --name=#{vmname} --register")
    created << {name: vmname, ipaddr: vmip, state: 'created'} 
  end
  File.open(VMFILE, 'w'){|f| f.puts(JSON.generate(created)) }
end

main()
