#!/usr/bin/env ruby

str = `VBoxManage list runningvms`
vms = str.strip().split("\n").map{|l| d=l.split(" "); d[0][1..-2]}
puts vms.join(" ")
