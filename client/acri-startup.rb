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
LOCK         = DATA_DIR + "/LOCK-UPDATE"
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
  open("#{XRDP_FILE}.base", "r"){ |f| str = f.read() }
  str.split("\n").each{|line|
    if(line == "username=ask") then
      line = "username=#{user}"
    end
    newstr += line + "\n"
  }
  open("#{XRDP_FILE}.#{host}", "w"){ |f| f.write(newstr) }
end
  
def generate_sshd_config(host, user)
  str = ""
  open("#{SSHD_FILE}.base", "r"){ |f| str = f.read() }
  str += "\n"
  str += "AllowUsers"
  str += " acriuser" # acriuser can alway login the host
  if user != nil then
    str += " " + user
  end
  str += "\n"
  open("#{SSHD_FILE}.#{host}", "w"){ |f| f.write(str) }
end

###########################################################
# main
###########################################################

def main()
  host = `hostname -s`.strip
  log = open("#{LOG_DIR}/#{host}.txt", 'a')

  log.puts "acri-startup started at #{Time.now}"

  ## Program FPGA
  num_boards = `lsusb | grep FT2232 | wc -l`.to_i
  tcl_file = nil
  if ! Dir.exist?(VIVADO_DIR)
    log.print "Vivado directory is not found."
  elsif num_boards == 0
    log.print "No Arty boards are found."
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
    # We have to explicitly remove temporary file created by the Digilent driver,
    # in order to let another user access to the board.
    system("rm -f /tmp/digilent-adept2-*")
  else
    log.puts " Skipping FPGA programming."
  end

  ## Find a user who can login at this time slot
  if tcl_file
    cur_user = nil
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
    log.puts "No valid user in this time slot" if ! cur_user
    log.puts "Valid user is #{cur_user}"       if   cur_user
  
    ## Generate new config files
    generate_sshd_config(host, cur_user)
    generate_xrdp_config(host, cur_user || 'acriuser')
  else
    log.puts "Turning off login restriction"
    system("cp #{SSHD_FILE}.base #{SSHD_FILE}.#{host}")
    system("cp #{XRDP_FILE}.base #{XRDP_FILE}.#{host}")
  end

  log.puts "acri-startup finished at #{Time.now}"
  log.puts
  log.close
end

main()