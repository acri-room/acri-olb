#!/usr/bin/env ruby

str = `VBoxManage list vms`
vms = str.strip().split("\n").map{|l| d=l.split(" "); d[0][1..-2]}
puts vms.join(" ")
