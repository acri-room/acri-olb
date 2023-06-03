#!/usr/bin/env ruby

require 'json'
require 'fileutils'

BASEDIR = "/tools/acri-olb"
DATADIR = BASEDIR + "/vm-host/data/"
VMFILE  = DATADIR + "created-vms.json"
LOGDIR  = BASEDIR + "/client/log/"
LOGFILE = LOGDIR + "setup-%s.txt"

WAIT_LIMIT = 30 # 2.5 minutes

def wait_printing_dot()
  print('.')
  STDOUT.flush
  sleep 5
end

###########################################################
# start, wait, and stop a VM to setup
###########################################################

def autosetup_vm(vmname, usbserial = nil)
  puts "## Starting the auto setup process of #{vmname}"
  if usbserial
    puts "## Assigning a board with serial number of #{usbserial}"
    system("VBoxManage modifyvm #{vmname} --usb off --usbxhci on")
    system("VBoxManage usbfilter add 0 --target #{vmname} " +
      '--name "Digilent USB Device [0700]" --vendorid 0403 --productid 6010 ' +
      '--revision 0700 --manufacturer Digilent --product "Digilent USB Device" ' +
      "--serialnumber #{usbserial}")
  end
  system("VBoxManage startvm #{vmname} --type headless")
  while ! File.exist?(LOGFILE % vmname) # generated after vm-host-setup.py is completed
    wait_printing_dot
  end
  puts
  system("VBoxManage controlvm #{vmname} acpipowerbutton")
  n = 0
  while true
    wait_printing_dot
    n += 1
    system("VBoxManage controlvm #{vmname} poweroff") if n == WAIT_LIMIT
    str = `VBoxManage list runningvms | grep #{vmname}`    
    break if str.strip.size == 0
  end
  puts
  puts "## Finished auto setup process of #{vmname}"
end

###########################################################
# main
###########################################################

def main()
  # Error Check
  if `VBoxManage list runningvms`.strip.size != 0
    puts "!! Please make sure no VMs are running."
    exit 1
  end
  if ! File.exist?(VMFILE)
    puts "!! VMs have not been cloned."
    exit 1
  end

  # Read JSON File to enumerate VMs to setup
  infile = File.read(VMFILE)
  injson = JSON.parse(infile.strip)
  vms = `#{BASEDIR}/vm-host/all-vms.rb`.split(' ')
  setup_vms = []
  injson.each_index do |i|
    next if injson[i]['state'] != 'created'
    vmname = injson[i]['name']
    if ! vms.include?(vmname)
      puts "!! #{vmname} was cloned but is not registered."
      exit 1
    end
    setup_vms << vmname
  end
  if setup_vms.empty?
    puts "## All VMs are ready. Setup is not required."
    exit 0
  end

  # Enumerate USB devices
  usb_devices = `VBoxManage list usbhost | grep SerialNumber`.strip.split("\n")
  usb_devices = usb_devices.select{|x| x =~ /[0-9A-F]{12}$/ }.map{|x| x[-12..-1] }
  usb_map = Hash.new
  setup_vms.each do |vmname|
    vmindex = vmname[-2..-1].to_i
    if vmindex != 0 && vmindex <= usb_devices.size
      usb_map[vmname] = usb_devices[vmindex - 1] 
    end
  end

  # Remove old setup log (if exists)
  FileUtils.rm_f(setup_vms.map{|vmname| LOGFILE % vmname })

  # Setup each of the VMs
  setup_vms.each{|vmname| autosetup_vm(vmname, usb_map[vmname]) }
end

main()