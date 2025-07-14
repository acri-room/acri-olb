#!/usr/bin/env ruby

require 'json'

TIMESPAN = 3
VIVADO_DIR   = '/tools/Xilinx/Vivado/2020.2'
SOURCE_DIR   = '/tools/acri-olb/vs_default'
BASE_DIR     = '/tools/acri-olb/client'	
LOG_DIR      = BASE_DIR + '/log'
SSHD_FILE    = BASE_DIR + "/setting/sshd_config"
XRDP_FILE    = BASE_DIR + "/setting/xrdp.ini"
DATA_DIR     = "/tools/acri-olb/vm-host/data"
DATA_FILE    = DATA_DIR + "/reservation.json"
VM_LIST_FILE = DATA_DIR + "/created-vms.json"
LOCK         = DATA_DIR + "/LOCK-UPDATE"
USER_NAME    = "acriuser"
USER_DIR     = "/usr/local/home/acriuser"
HOST_FILE    = USER_DIR + "/new_hostname.txt"
SSHD_GEN     = USER_DIR + "/new_sshd_config"
XRDP_GEN     = USER_DIR + "/new_xrdp.ini"
ALLOW_FILE   = USER_DIR + "/new_allowuser.txt"
TCL_FILES    =
  {'01' => 'config_board_1.tcl', '02' => 'config_board_2.tcl',
   '03' => 'config_board_3.tcl', '04' => 'config_board_4.tcl',
   '05' => 'config_board_5.tcl', '06' => 'config_board_6.tcl',
   '07' => 'config_board_7.tcl', '08' => 'config_board_8.tcl',
   '09' => 'config_board_9.tcl', '10' => 'config_board_A.tcl',
   '11' => 'config_board_B.tcl', '12' => 'config_board_C.tcl',
   '13' => 'config_board_D.tcl', '14' => 'config_board_E.tcl',
   '15' => 'config_board_F.tcl'}

def generate_xrdp_config(host, user)
  str = ""
  newstr = ""
  user = user || USER_NAME
  open("#{XRDP_FILE}.base", "r"){ |f| str = f.read() }
  str.split("\n").each{|line|
    if line == "username=ask" && user != 'everyone'
      line = "username=#{user}"
    end
    if line =~ /^#ls_title=/ && user != 'everyone'
      line = "ls_title=Login to #{host} (User: #{user})"
    end
    newstr += line + "\n"
  }
  open("#{XRDP_GEN}", "w"){ |f| f.write(newstr) }
end
  
def generate_sshd_config(user)
  str = ""
  open("#{SSHD_FILE}.base", "r"){ |f| str = f.read() }
  if user != 'everyone'
    str += "\n"
    str += "AllowUsers"
    str += " " + USER_NAME # admin user can alway login the host
    if user != nil then
      str += " " + user
    end
    str += "\n"
  end
  open("#{SSHD_GEN}", "w"){ |f| f.write(str) }
end

def generate_allow_file(user, log)
  if user && user != 'everyone' && user != 'closed'
    open("#{ALLOW_FILE}", "w"){ |f| f.print user }
  elsif File.exist?(ALLOW_FILE)
    begin
      File.delete(ALLOW_FILE)
    rescue
      log.puts "An error occurred while deleting file"
    end
  end
end

###########################################################
# VM setup (executed if hostname ends with "skel")
###########################################################
def vm_setup_check(log)
  log.puts "Check if VM setup is required..."
  open(LOCK, 'w') do |lock|
    lock.flock(File::LOCK_EX) # get DB lock
    if ! File.exist?(VM_LIST_FILE)
      log.puts "VMs have not been cloned. Setup is not required."
      return
    end
    vmname = vmip = nil
    infile = File.read(VM_LIST_FILE)
    injson = JSON.parse(infile.strip)
    injson.each_index do |i|
      if injson[i]['state'] == 'created'
        vmname = injson[i]['name']
        vmip = injson[i]['ipaddr']
        injson[i]['state'] = 'ready'
        break
      end
    end
    if vmname
      File.open(VM_LIST_FILE, 'w'){|f| f.puts(JSON.generate(injson)) }
      File.open(HOST_FILE, 'w'){|f| f.puts vmname; f.puts vmip }
      log.puts "Setup is required. New hostname is #{vmname}."
    else
      log.puts "All VMs are ready. Setup is not required."
    end
  end
end

###########################################################
# main
###########################################################

def main()
  host = `hostname -s`.strip
  log = open("#{LOG_DIR}/#{host}.txt", 'a')

  log.puts "acri-startup started at #{Time.now}"

  if host.end_with?("skel")
    vm_setup_check(log)
  else
    ## Program FPGA
    num_boards = `lsusb | grep FT2232 | wc -l`.to_i
    tcl_file = nil
    no_vivado = false
    if ! Dir.exist?(VIVADO_DIR)
      log.print "Vivado directory is not found."
      no_vivado = true
    elsif num_boards == 0
      log.print "No FPGA boards are found."
    else
      tcl_file = TCL_FILES[host[-2..-1]]
      log.print "No bit files are prepared." if ! tcl_file
    end

    if tcl_file
      log.puts "Program FPGA with #{tcl_file}"
      newenv = {
        'PATH' => VIVADO_DIR + '/bin;' + ENV['PATH'],
        'XILINX_VIVADO' => VIVADO_DIR }
      Dir.chdir(SOURCE_DIR) do
        IO.popen([newenv, VIVADO_DIR + '/bin/vivado',
          '-mode', 'batch', '-source', tcl_file, '-nojournal']) do |io|
          while line = io.gets
            log.puts line.chomp if line =~ /^# [a-z]/ || line =~ /: Time \(s\)/
          end
        end
      end
      log.puts "Exit code of Vivado: #{$? >> 8}"
      system("killall -9 hw_server")
    else
      log.puts " Skipping FPGA programming."
    end

    ## Find a user who can login at this time slot
    cur_user = nil
    if tcl_file || no_vivado
      open(LOCK, 'w') do |lock|
        lock.flock(File::LOCK_EX) # get DB lock
        begin
          infile = File.read(DATA_FILE)
          injson = JSON.parse(infile.strip)
          cur_user = injson['reserve'][host] && injson['reserve'][host]['new']
        rescue
          cur_user = nil
        end
        lock.flock(File::LOCK_UN) # release DB lock
      end
    else
      cur_user = 'everyone'
    end

    log.puts "No valid user in this time slot" if ! cur_user
    log.puts "Valid user is #{cur_user}"       if   cur_user && cur_user != 'everyone'
    log.puts "Turning off login restriction"   if   cur_user && cur_user == 'everyone'
    ## Generate new config files
    generate_sshd_config(cur_user)
    generate_xrdp_config(host, cur_user)
    generate_allow_file(cur_user, log)
  end

  log.puts "acri-startup finished at #{Time.now}"
  log.puts
  log.close
end

main()